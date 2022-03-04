# frozen_string_literal: true

require "aws-sdk-sqs"
require "active_support"
require "active_support/core_ext/string/inflections"
require_relative "broker/aws/sns/publisher"

module PipefyMessage
  # Aws SNS Publisher class to publish json messages into a specific topic
  class BasePublisher

    def publish(message, topic_name)

      default_topic_path = "arn:aws:sns:us-east-1:000000000000:"
      result = publisher_instance.publish(message, default_topic_path + topic_name)
      puts result
      result
    end

    def self.publisher_implementation
      ENV["PUBLISHER_IMPL"] || "SnsPublisher"
    end

    def self.resolve_publisher_module(publisher_name)
      publishers_module = Hash["SnsPublisher" => "Aws::SnsPublisher"]
      publishers_module[publisher_name]
    end

    def self.publisher_instance
      "PipefyMessage::Publisher::#{resolve_publisher_module.to_s.camelize}".constantize
    end
  end
end
