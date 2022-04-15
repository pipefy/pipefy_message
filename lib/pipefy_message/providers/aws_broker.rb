require "aws-sdk-sqs"
require "json"

module PipefyMessage
  module Providers
    class AwsBroker < Broker
      def initialize(queue_name)
        @config = build_options
        Aws.config.update(@config)

        @sqs = Aws::SQS::Client.new
        # require 'pry'; binding.pry
        queue_url = @sqs.get_queue_url({ queue_name: queue_name }).queue_url
        @poller = Aws::SQS::QueuePoller.new(queue_url)

        @wait_time_seconds = 10
      rescue Aws::SQS::Errors::NonExistentQueue, Seahorse::Client::NetworkingError => e
        raise PipefyMessage::Providers::Errors::ResourceError, e.message
      end

      def default_options
        {
          access_key_id: (ENV["AWS_ACCESS_KEY_ID"] || "foo"),
          secret_access_key: (ENV["AWS_SECRET_ACCESS_KEY"] || "bar"),
          endpoint: (ENV["AWS_ENDPOINT"] || "http://localhost:4566"),
          region: (ENV["AWS_REGION"] || "us-east-1"),
          stub_responses: (ENV["AWS_CLI_STUB_RESPONSE"] == "true")
        }
      end

      def build_options
        default_options.merge({})
      end

      def poller
        ## Aws poller
        @poller.poll(wait_time_seconds: @wait_time_seconds) do |received_message|
          payload = JSON.parse(received_message.body)
          yield(payload)
        end
      end
    end
  end
end
