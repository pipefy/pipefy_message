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

          @topic_arn_prefix = ENV.fetch("AWS_SNS_ARN_PREFIX", "arn:aws:sns:us-east-1:000000000000")
          @is_staging = ENV["ASYNC_APP_ENV"] == "staging"

          queue_url = @sqs.get_queue_url({ queue_name: @config[:queue_name] }).queue_url.sub(%r{^http://}, "https://")

          @poller = Aws::SQS::QueuePoller.new(queue_url, { client: @sqs })
        rescue StandardError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Initiates SQS queue polling, with wait_time_seconds as given
        # in the initial configuration.
        def poller
          logger.info(build_log_hash("Initiating SQS polling on queue #{@config[:queue_name]}"))

          @poller.poll(wait_time_seconds: @config[:wait_time_seconds]) do |received_message|
            logger.debug(build_log_hash("Message received by SQS poller on queue #{@config[:queue_name]}"))

            payload = JSON.parse(received_message.body)
            yield(payload)

          rescue StandardError => e
            raise PipefyMessage::Providers::Errors::ResourceError, e.message
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
      end
    end
  end
end
