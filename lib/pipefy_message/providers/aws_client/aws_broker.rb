# frozen_string_literal: true

require "aws-sdk-sqs"
require "json"

module PipefyMessage
  module Providers
    module AwsClient
      ##
      # "Abstract" superclass for brokers of AWS services, implementing
      # AWS option parsing and connection setup.
      class AwsBroker < PipefyMessage::Providers::Broker
        def initialize(opts = {})
          @config = build_options(opts)
          Aws.config.update(@config[:aws])
          logger.debug({ options_set: @config, message_text: "AWS connection set up with options_set" })
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
            wait_time_seconds: 10
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

        private

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
