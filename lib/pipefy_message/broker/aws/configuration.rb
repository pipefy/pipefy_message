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
          Aws.config.update(retrieve_config)
        end

        private

        def aws_client_config?
          ENV["ENABLE_AWS_CLIENT_CONFIG"] == "true"
        end

        def retrieve_config
          config = { region: ENV["AWS_REGION"] || "us-east-1" }
          merge_custom_config(config)
        end

        def merge_custom_config(config)
          if aws_client_config?
            { access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
              endpoint: ENV["AWS_ENDPOINT"], stub_responses: ENV["AWS_CLI_STUB_RESPONSE"] || false }.merge(config)
          else
            config
          end
        end
      end
    end
  end
end
