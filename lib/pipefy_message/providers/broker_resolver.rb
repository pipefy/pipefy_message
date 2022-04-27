# frozen_string_literal: true

module PipefyMessage
  module Providers
    ##
    # Provides class names and paths to be used for each type of
    # client, for each provider.
    module BrokerResolver
      def self.class_path
        {
          aws: {
            publisher: {
              class_name: "PipefyMessage::Providers::AwsClient::SnsBroker",
              relative_path: "providers/aws_client/sns_broker"
            },
            consumer: {
              class_name: "PipefyMessage::Providers::AwsClient::SqsBroker",
              relative_path: "providers/aws_client/sqs_broker"
            }
          }
        }
      end
    end
  end
end
