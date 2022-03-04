# frozen_string_literal: true

require "aws-sdk-sqs"
require_relative "broker/aws/sqs/consumer"

module PipefyMessage
  # Base Consumer class provide by this gem, to be used for the external consumers to consume messages from a broker
  class BaseConsumer < Consumer::AwsProvider::SqsConsumer
    def process_message(message)
      puts "Processing Message"
      puts "Message body: #{message}"
      message
    end
  end
end
