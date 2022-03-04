# frozen_string_literal: true

require "aws-sdk-sns"
require "singleton"

module PipefyMessage
  module BrokerConfiguration
    module AwsProvider
      # Aws Provider Config class to connect with the cloud resources
      class ProviderConfig
        include Singleton

        def setup_connection
          Aws.config.update(
            endpoint: ENV["AWS_ENDPOINT"],
            access_key_id: ENV["AWS_ACCESS_KEY_ID"],
            secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
            region: ENV["AWS_REGION"] || "us-east-1",
            stub_responses: ENV["AWS_CLI_STUB_RESPONSE"] || false
          )
        end
      end
    end
  end
end
