# frozen_string_literal: true

require_relative "aws_client"

module PipefyMessage
  module Providers
    module AwsClient
      ##
      # AWS SQS client.
      class SqsBroker
        include PipefyMessage::Logging
        include PipefyMessage::Providers::Errors

        def initialize(opts = {})
          @config = default_options.merge(opts)

          AwsClient.aws_setup

          @sqs = Aws::SQS::Client.new
          logger.debug({ message_text: "SQS client created" })
          @is_staging = ENV["ASYNC_APP_ENV"] == "staging"

          @queue_url = handle_queue_protocol(@sqs.get_queue_url({ queue_name: handle_queue_name(@config[:queue_name]) })
                                                 .queue_url)

          @poller = Aws::SQS::QueuePoller.new(@queue_url, { client: @sqs })
        rescue StandardError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Initiates SQS queue polling, with wait_time_seconds as given
        # in the initial configuration.
        def poller
          logger.info(build_log_hash("Initiating SQS polling on queue #{@queue_url}"))

          @poller.poll({ wait_time_seconds: @config[:wait_time_seconds],
                         message_attribute_names: ["All"], attribute_names: ["All"] }) do |received_message|
            logger.debug(build_log_hash("Message received by SQS poller on queue #{@queue_url}"))

            payload = JSON.parse(received_message.body)
            metadata = received_message.message_attributes.merge(received_message.attributes)
            yield(payload, metadata)
          rescue StandardError => e
            # error in the routine, skip delete to try the message again later with 30sec of delay
            logger.error("Failed to process message, details #{e.inspect}")

            throw e if e.instance_of?(NameError)

            throw :skip_delete
          end
        end

        private

        ##
        # Extends AWS default options to include a value
        # for SQS-specific configurations.
        def default_options
          { wait_time_seconds: 10, queue_name: "pipefy-local-queue" }
        end

        ##
        # Adds the queue name to logs, if not already present.
        def build_log_hash(arg)
          { queue_name: @config[:queue_name], message_text: arg }
        end

        ##
        # Adds the staging suffix to queue names where applicable.
        def handle_queue_name(queue_name)
          @is_staging ? "#{queue_name}-staging" : queue_name
        end

        def handle_queue_protocol(queue_url)
          ENV["ASYNC_APP_ENV"] == "development" ? queue_url : queue_url.sub(%r{^http://}, "https://")
        end
      end
    end
  end
end
