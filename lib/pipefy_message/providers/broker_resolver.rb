# frozen_string_literal: true

module PipefyMessage
  module Providers
    ##
    # Provides class names and paths to be used for each type of
    # client, for each provider.
    module BrokerResolver
      ##
      # Initializes and returns an instance of a broker for
      # the provider specified in the class options.
      def self.resolve_broker(broker, type)
        provider_map = class_path[broker.to_sym]

        if provider_map.nil?
          error_msg = "Invalid provider specified: #{broker}"

          raise PipefyMessage::Providers::Errors::InvalidOption, error_msg
        end

        map = provider_map[:type]
        require_relative map[:relative_path]

        logger.info({
                      broker: broker,
                      message_text: "Initializing instance of #{broker} #{type}"
                    })

        map
      end

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
