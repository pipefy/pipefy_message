# frozen_string_literal: true

require "aws-sdk-sqs"
require "json"

module PipefyMessage
  module Providers
    ##
    # Provides an AWS connection configuration "lazy loader" and classes
    # for AWS service brokers.
    module AwsClient
      include PipefyMessage::Logging

      ##
      # Sets up AWS options the first time an AWS service is used.
      def self.aws_setup
        logger.info({ log_text: "AWS configurations set" })
        Aws.config.update(retrieve_config)
      end

      def self.aws_client_config?
        ENV["ENABLE_AWS_CLIENT_CONFIG"] == "true"
      end

      # Hash that fetches AWS options from environment variables or
      # sets the base and custom values.
      def self.retrieve_config
        config = { region: ENV.fetch("AWS_REGION", "us-east-1") }
        merge_custom_config(config)
      end

      def self.merge_custom_config(config)
        if aws_client_config?
          {
            access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID", "foo"),
            secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", "bar"),
            endpoint: ENV.fetch("AWS_ENDPOINT", "http://localhost:4566"),
            stub_responses: ENV.fetch("AWS_CLI_STUB_RESPONSE", false)
          }.merge(config)
        else
          config
        end
      end
    end
  end
end
