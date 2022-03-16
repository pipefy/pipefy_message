# frozen_string_literal: true

require "aws-sdk-sns"
require "json"
require "logger"
require_relative "../configuration"

module PipefyMessage
  module Publisher
    module AwsProvider
      # Aws SNS Publisher class to publish json messages into a specific topic
      class SnsPublisher
        def initialize
          aws_config = PipefyMessage::BrokerConfiguration::AwsProvider::ProviderConfig.instance
          aws_config.setup_connection
          @sns = Aws::SNS::Resource.new
          @log = Logger.new($stdout)
        end

        def publish(payload, topic_arn)
          message = prepare_payload(payload)
          do_publish(message, topic_arn)
        end

        private

        def prepare_payload(payload)
          # The 'Default' json key/entry it's mandatory to ruby sdk
          {
            "default" => payload
          }
        end

        def do_publish(message, topic_arn)
          topic = @sns.topic(topic_arn)

          @log.info("Publishing a json message to topic #{topic_arn}")
          result = topic.publish({
                                   message: message.to_json,
                                   message_structure: "json"
                                 })
          @log.info("Message Published with ID #{result.message_id}")
          result
        rescue StandardError
          @log.error("Failed to publish message [#{message}]")
        end
      end
    end
  end
end
