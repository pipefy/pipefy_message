# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/broker/aws/configuration"
require_relative "pipefy_message/broker/aws/sns/publisher"
require_relative "pipefy_message/base_consumer"
require_relative "pipefy_message/base_publisher"
require_relative "pipefy_message/worker"
require_relative "pipefy_message/providers/broker"
require_relative "pipefy_message/providers/errors"
require_relative "pipefy_message/logging" # shared logger config
require "logger"
require "json"
require "benchmark"

module PipefyMessage
  def self.default_worker_options
    @default_worker_options ||= {
      "broker" => "aws",
      "queue_name" => "my_queue"
    }
  end

  # Simple Test class to validate the project
  class Test
    include Logging

    def publish
      payload = { foo: "bar" }
      puts Publisher::BasePublisher.new.publish(payload, "pipefy-local-topic")
    end

    def consume
      logger.info("Starting the consumer process")
      consumer = BaseConsumer.new("http://localhost:4566/000000000000/pipefy-local-queue")
      logger.info("Creating new instance of consumer #{consumer}")
      consumer.consume_message
    end

    def publish_and_consume
      publish
      consume
    end
  end
end
