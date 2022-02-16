# frozen_string_literal: true

require "aws-sdk-sqs"
require "json"

module PipefyMessage
  # Aws SNS Publisher class to publish json messages into a specific topic
  class SqsConsumer
    def initialize(queue_url)
      aws_config = PipefyMessage::AwsProviderConfig.instance
      aws_config.setup_connection
      @poller = Aws::SQS::QueuePoller.new(queue_url)
    end

    def consume_message
      @poller.poll(wait_time_seconds: 10) do |received_message|
        puts "Receiving Message from Broker"
        puts "Message ID:   #{received_message.message_id}"
        payload = JSON.parse(received_message.body)

        process_message(payload["Message"])

      rescue StandardError
        puts "Failed to process message with ID: #{received_message.message_id}"
        throw :skip_delete
      end
    end

    def process_message(_message)
      raise "Must be implemented by a worker class"
    end
  end
end
