# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/broker/aws/configuration"
require_relative "pipefy_message/broker/aws/sns/publisher"
require_relative "pipefy_message/base_consumer"
require_relative "pipefy_message/base_publisher"
require "pry"

module PipefyMessage
  # Simple Test class to validate the project
  class Test
    def publish
      payload = { foo: "bar" }
      puts Publisher.publish(payload, "arn:aws:sns:us-east-1:000000000000:pipefy-local-topic")
    end

    def consume
      puts "Starting the consumer process"
      consumer = BaseConsumer.new("http://localhost:4566/000000000000/pipefy-local-queue")
      puts "Creating new instance of consumer #{consumer}"
      consumer.consume_message
    end

    def publish_and_consume
      publish
      consume
    end
  end
end
