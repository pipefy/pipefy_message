require "aws-sdk-sns"
require_relative "aws_broker"

module PipefyMessage
  module Providers
    module AwsClient
      # AWS SNS client.
      class SnsBroker < PipefyMessage::Providers::AwsClient::AwsBroker
        attr_reader :config

        def initialize(opts = {})
          super(opts)

          @sns = Aws::SNS::Resource.new
          @topic_arn_prefix = ENV["AWS_SNS_ARN_PREFIX"] || @config[:default_arn_prefix]
          @is_staging = ENV["ASYNC_APP_ENV"] == "staging"
        rescue Aws::SNS::Errors::ServiceError, Seahorse::Client::NetworkingError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Publishes a message with the given payload to the SNS topic
        # with topic_name.
        def publish(payload, topic_name)
          message = prepare_payload(payload)
          topic_arn = @topic_arn_prefix + (@is_staging ? "#{topic_name}-staging" : topic_name)
          topic = @sns.topic(topic_arn)

          logger.info(
            { topic_arn: topic_arn,
              payload: payload,
              message_text: "Attempting to publish a json message to topic #{topic_arn}" }
          )

          result = topic.publish({ message: message.to_json, message_structure: " json " })

          logger.info(
            { topic_arn: topic_arn,
              id: result.message_id,
              message_text: "Message published with ID #{result.message_id}" }
          )

          result
        rescue StandardError => e
          logger.error(
            { topic_arn: topic_arn,
              message_text: "Failed to publish message",
              error_details: e.inspect }
          )
        end

        private

        ##
        # "Wraps" the message payload as the value of the "default" key
        # in a hash, as specified by the AWS Ruby SDK.
        def prepare_payload(payload)
          {
            "default" => payload
          }
        end
      end
    end
  end
end
