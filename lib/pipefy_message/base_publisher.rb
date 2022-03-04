# frozen_string_literal: true

require "aws-sdk-sqs"
require "active_support"
require "active_support/core_ext/string/inflections"
require_relative "broker/aws/sns/publisher"

module PipefyMessage
  # Publisher class provide by this gem, to be used for the external publishers to send messages to a broker
  module Publisher
    module_function

    def publish(message, topic)
      result = publisher_instance.new.publish(message, topic)
      puts result
      result
    end

    def self.publisher_implementation
      ENV["PUBLISHER_IMPL"] || "SnsPublisher"
    end

    def self.resolve_publisher_module(publisher_name)
      publishers_module = Hash["SnsPublisher" => "AwsProvider::SnsPublisher"]
      publishers_module[publisher_name]
    end

    def self.publisher_instance
      "PipefyMessage::Publisher::#{resolve_publisher_module(publisher_implementation).to_s.camelize}".constantize
    end
  end
end
