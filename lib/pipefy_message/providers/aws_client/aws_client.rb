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
      # Hash that fetches AWS options from environment variables or
      # sets them to default values.
      def self.set_options
        {
          access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID", "foo"),
          secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", "bar"),
          endpoint: ENV.fetch("AWS_ENDPOINT", "http://localhost:4566"),
          region: ENV.fetch("AWS_REGION", "us-east-1"),
          stub_responses: ENV.fetch("AWS_CLI_STUB_RESPONSE", "true")
        }
      end

      ##
      # Sets up AWS options the first time an AWS service is used.
      def self.aws_setup
        return unless Aws.config.empty?

        logger.info({ message_text: "AWS configurations set" })

        Aws.config.update(set_options)
      end
    end
  end
end
