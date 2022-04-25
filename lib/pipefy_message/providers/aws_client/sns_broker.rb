require "aws-sdk-sqs"
require "json"
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
        rescue StandardError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Hash with default options to be used in AWS access configuration
        # if no overriding parameters are provided.
        def default_options
          {
            access_key_id: (ENV["AWS_ACCESS_KEY_ID"] || "foo"),
            secret_access_key: (ENV["AWS_SECRET_ACCESS_KEY"] || "bar"),
            endpoint: (ENV["AWS_ENDPOINT"] || "http://localhost:4566"),
            region: (ENV["AWS_REGION"] || "us-east-1"),
            stub_responses: (ENV["AWS_CLI_STUB_RESPONSE"] == "true"),
            wait_time_seconds: 10,
            default_arn_prefix: "arn:aws:sns:us-east-1:000000000000:"
          }
        end

        ##
        # Merges default options (returned by default_options) with the
        # hash provided as an argument. The latter takes precedence.
        def build_options(opts)
          hash = default_options.merge(opts)
          aws_hash = isolate_broker_arguments(hash)

          config_hash = {
            aws: aws_hash
          }

          hash.each do |k, v|
            config_hash[k] = v unless aws_hash.key?(k)
          end

          config_hash
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

        ##
        # Options hash parser.
        def isolate_broker_arguments(hash)
          {
            access_key_id: hash[:access_key_id],
            secret_access_key: hash[:secret_access_key],
            endpoint: hash[:endpoint],
            region: hash[:region],
            stub_responses: hash[:stub_responses]
          }
        end
      end
    end
  end
end
