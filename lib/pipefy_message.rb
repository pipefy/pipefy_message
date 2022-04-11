# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/broker/aws/configuration"
require_relative "pipefy_message/broker/aws/sns/publisher"
require_relative "pipefy_message/base_consumer"
require_relative "pipefy_message/base_publisher"
require_relative "pipefy_message/logger"
require_relative "pipefy_message/worker"
require "logger"

module PipefyMessage
  # Simple Test class to validate the project
  class Test
    def initialize
      @log = PipefyMessage::CustomLogger.new
    end

    def publish
      payload = { foo: "bar" }
      puts Publisher::BasePublisher.new.publish(payload, "pipefy-local-topic")
    end

    def consume
      @log.info("Starting the consumer process")
      consumer = BaseConsumer.new("http://localhost:4566/000000000000/pipefy-local-queue")
      @log.info("Creating new instance of consumer #{consumer}")
      consumer.consume_message
    end

    def publish_and_consume
      publish
      consume
    end
  end
end
