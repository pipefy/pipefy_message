# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/configuration"
require_relative "pipefy_message/broker/aws/sns/publisher"
require_relative "pipefy_message/base_consumer"
require "pry"

module PipefyMessage
  # Simple Test class to validate the project
  class Test
    def publish
      publisher = SnsPublisher.new
      payload = { foo: "bar" }
      puts publisher.publish(payload, "arn:aws:sns:us-east-1:000000000000:pipefy-local-topic")
    end

    def consume
      puts "Starting the consumer process"
      consumer = BaseConsumer.new("http://localhost:4566/000000000000/pipefy-local-queue")
      puts "Creating new instance of consumer #{consumer}"
      consumer.receive_message
    end

    def publish_and_consume
      publish
      consume
    end
  end
end
