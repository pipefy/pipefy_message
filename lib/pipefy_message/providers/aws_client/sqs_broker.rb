# frozen_string_literal: true

require_relative "aws_broker"

module PipefyMessage
  module Providers
    module AwsClient
      ##
      # AWS SQS client.
      class SqsBroker < PipefyMessage::Providers::AwsClient::AwsBroker
        attr_reader :config

        def initialize(opts = {})
          super(opts)

          @sqs = Aws::SQS::Client.new
          logger.debug({ message_text: "SQS client created" })

          queue_url = @sqs.get_queue_url({ queue_name: @config[:queue_name] }).queue_url
          @poller = Aws::SQS::QueuePoller.new(queue_url, { client: @sqs })
        rescue StandardError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Extends AWS default options to include a value
        # for SQS-specific configurations.
        def default_options
          aws_defaults = super
          aws_defaults[:wait_time_seconds] = 10
          aws_defaults[:queue_name] = "pipefy-local-queue"

          aws_defaults
        end

        ##
        # Initiates SQS queue polling, with wait_time_seconds as given
        # in the initial configuration.
        def poller
          logger.debug(build_log_hash("Initiating SQS polling on queue #{@config[:queue_name]}"))

          @poller.poll(wait_time_seconds: @config[:wait_time_seconds]) do |received_message|
            logger.debug(build_log_hash("Message received by SQS poller on queue #{@config[:queue_name]}"))

            payload = JSON.parse(received_message.body)
            yield(payload)
          end
        end

        ##
        # Adds the queue name to logs, if not already present.
        def build_log_hash(arg)
          if arg.instance_of? Hash
            { queue_name: @config[:queue_name] }.merge(arg)
          else
            { queue_name: @config[:queue_name], message_text: arg }
          end
        end
      end
    end
  end
end
