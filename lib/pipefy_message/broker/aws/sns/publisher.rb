# frozen_string_literal: true

require "aws-sdk-sns"
require "json"
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

          puts "Publishing a json message to topic #{topic_arn}"
          result = topic.publish({
                                   message: message.to_json,
                                   message_structure: "json"
                                 })
          puts result
          puts "Message Published with ID #{result.message_id}"
        end
      end
    end
  end
end