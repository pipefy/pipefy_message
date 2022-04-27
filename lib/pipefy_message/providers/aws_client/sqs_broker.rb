# frozen_string_literal: true

require_relative "aws_broker"

module PipefyMessage
  module Providers
    module AwsClient
      ##
      # AWS SQS client.
      class SqsBroker < PipefyMessage::Providers::AwsClient::AwsBroker
        attr_reader :config

        def initialize(queue_name, opts = {})
          super(opts)

          @sqs = Aws::SQS::Client.new
          queue_url = @sqs.get_queue_url({ queue_name: queue_name }).queue_url
          @poller = Aws::SQS::QueuePoller.new(queue_url, { client: @sqs })
        rescue StandardError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Extends AWS default options to include a value
        # for queue poller wait times.
        def default_options
          aws_defaults = super
          aws_defaults[:wait_time_seconds] = 10

          aws_defaults
        end

        ##
        # Initiates SQS queue polling, with wait_time_seconds as given
        # in the initial configuration.
        def poller
          logger.debug({ message_text: "Initiating SQS polling..." })

          @poller.poll(wait_time_seconds: @config[:wait_time_seconds]) do |received_message|
            logger.debug({ message_text: "Message received by SQS poller" })
            payload = JSON.parse(received_message.body)
            yield(payload)
          end
        end
      end
    end
  end
end
