# frozen_string_literal: true

require "aws-sdk-sns"
require "singleton"

module PipefyMessage
  # Aws Provider Config class to connect with the cloud resources
  class AwsProviderConfig
    include Singleton

    def do_connection
      Aws.config.update(
        endpoint: ENV["AWS_ENDPOINT"],
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
        region: ENV["AWS_REGION"] || "us-east-1"
      )
    end
  end
end
