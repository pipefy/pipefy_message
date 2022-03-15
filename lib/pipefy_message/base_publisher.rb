# frozen_string_literal: true

require "aws-sdk-sqs"
require "aws-sdk-sns"
require "active_support"
require "active_support/core_ext/string/inflections"
require_relative "broker/aws/sns/publisher"

module PipefyMessage
  module Publisher
    # Base Publisher provided by this gem, to be used for the external publishers to send messages to a broker
    class BasePublisher
      def publish(message, topic)
        publisher_instance.publish(message, topic)
      end

      private

      def publisher_implementation
        ENV["PUBLISHER_IMPL"] || "SnsPublisher"
      end

      def resolve_publisher(publisher_name)
        publishers_module = Hash["SnsPublisher" => "AwsProvider::SnsPublisher"]
        "PipefyMessage::Publisher::#{publishers_module[publisher_name].to_s.camelize}".constantize
      end

      def publisher_instance
        resolve_publisher(publisher_implementation).new
      end
    end
  end
end
