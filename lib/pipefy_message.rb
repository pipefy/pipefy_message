# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/configuration"
require_relative "pipefy_message/broker/aws/sns/publisher"
require "pry"

module PipefyMessage
  # Simple Test class to validate the project
  class Test
    def hello


      publisher = SnsPublisher.new

      payload = { foo: "bar" }

      puts publisher.publish(payload, "arn:aws:sns:us-east-1:000000000000:pipefy-local-topic")
      puts "It's Alive !"
    end
  end
end
