# frozen_string_literal: true

require "aws-sdk-sqs"
require "json"
require "logger"

module PipefyMessage
  module Consumer
    module AwsProvider
      # Aws SQS Consumer class to consume json messages from a specific queue
      class SqsConsumer
        def initialize(queue_url)
          PipefyMessage::BrokerConfiguration::AwsProvider::ProviderConfig.instance.setup_connection
          @poller = Aws::SQS::QueuePoller.new(queue_url)
          @wait_time_seconds = ENV["AWS_SQS_CONSUME_WAIT_TIME_SEC"] || 10
          @log = Logger.new($stdout)
        end

        def consume_message
          @poller.poll(wait_time_seconds: @wait_time_seconds) do |received_message|
            @log.info("Receiving Message from Broker")
            @log.info("Message ID:   #{received_message.message_id}")
            payload = JSON.parse(received_message.body)

            process_message(payload["Message"])

          rescue StandardError
            @log.error("Failed to process message with ID: #{received_message.message_id}")
            throw :skip_delete
          end
        end

        def process_message(_message)
          raise "Must be implemented by a worker class"
        end
      end
    end
  end
end
