require_relative "aws_broker"

module PipefyMessage
  module Providers
    module AwsClient
      # AWS SNS client.
      class SnsBroker < PipefyMessage::Providers::AwsClient::AwsBroker
        attr_reader :config

        def initialize(opts = {})
          @config = build_options(opts)
          Aws.config.update(@config[:aws])
          logger.debug({ options_set: @config, message_text: "AWS connection opened with options_set" })

          @sns = Aws::SNS::Resource.new
          @topic_arn_prefix = ENV["AWS_SNS_ARN_PREFIX"] || @config[:default_arn_prefix]
          @is_staging = ENV["ASYNC_APP_ENV"] == "staging"
        rescue Aws::SNS::Errors::ServiceError, Seahorse::Client::NetworkingError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        def publish(payload, topic_name)
          message = prepare_payload(payload)
          topic_arn = @topic_arn_prefix + (@is_staging ? "#{topic_name}-staging" : topic_name)
          topic = @sns.topic(topic_arn)

          logger.info("Publishing a json message to topic #{topic_arn}")
          result = topic.publish({ message: message.to_json, message_structure: " json " })
          logger.info(" Message Published with ID #{result.message_id}")
          result
        rescue StandardError => e
          logger.error("Failed to publish message [#{message}], error details: [#{e.inspect}]")
        end

        private

        def prepare_payload(payload)
          # The 'Default' json key/entry is mandatory to ruby sdk
          {
            "default" => payload
          }
        end
      end
    end
  end
end
