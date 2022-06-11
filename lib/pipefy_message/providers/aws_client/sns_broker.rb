# frozen_string_literal: true

require "aws-sdk-sns"
require "securerandom"
require_relative "aws_client"

module PipefyMessage
  module Providers
    module AwsClient
      ##
      # AWS SNS client.
      class SnsBroker
        include PipefyMessage::Logging
        include PipefyMessage::Providers::Errors

        def initialize(_opts = {})
          AwsClient.aws_setup

          @sns = Aws::SNS::Resource.new
          logger.debug({ message_text: "SNS resource created" })

          @topic_arn_prefix = ENV.fetch("AWS_SNS_ARN_PREFIX", "arn:aws:sns:us-east-1:000000000000:")
          @is_staging = ENV["ASYNC_APP_ENV"] == "staging"
        rescue StandardError
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Publishes a message with the given payload to the SNS topic
        # with topic_name.
        def publish(payload, topic_name, context = "NO_CONTEXT_PROVIDED")
          message = prepare_payload(payload)
          topic_arn = @topic_arn_prefix + (@is_staging ? "#{topic_name}-staging" : topic_name)
          topic = @sns.topic(topic_arn)

          logger.info(
            { topic_arn: topic_arn,
              payload: payload,
              message_text: "Attempting to publish a json message to topic #{topic_arn}}" }
          )

          result = topic.publish({ message: message.to_json, message_structure: " json ",
                                   message_attributes: {
                                     "correlationId" => {
                                       data_type: "String",
                                       string_value: SecureRandom.uuid.to_s
                                     },
                                     "context" => {
                                       data_type: "String",
                                       string_value: context
                                     }
                                   } })

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
