# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/broker/aws/configuration"
require_relative "pipefy_message/logging"
require_relative "pipefy_message/publisher"
require_relative "pipefy_message/worker"
require_relative "pipefy_message/providers/broker"
require_relative "pipefy_message/providers/errors"

require "logger"
require "json"
require "benchmark"

##
# PipefyMessage abstraction async process
##
module PipefyMessage
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
