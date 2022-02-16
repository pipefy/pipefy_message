# frozen_string_literal: true

require "aws-sdk-sqs"
require_relative "broker/aws/sqs/consumer"

module PipefyMessage
  # Aws SNS Publisher class to publish json messages into a specific topic
  class BaseConsumer < SqsConsumer
    def process_message(message)
      puts "Processing Message"
      puts "Message body: #{message}"
      message
    end
  end
end
