require "aws-sdk-sqs"
require "json"

module PipefyMessage
  module Providers
    # AWS SQS client.
    class AwsBroker < Broker
      attr_reader :config

      def initialize(queue_name, opts = {})
        @config = build_options(opts)
        Aws.config.update(@config[:aws])

        logger.debug(JSON.dump({
          :options_set => @config,
          :message_text => "AWS connection opened with options_set"
        }))

        @sqs = Aws::SQS::Client.new

        queue_url = @sqs.get_queue_url({ queue_name: queue_name }).queue_url

        logger.debug(JSON.dump({
          :sqs_queue_name => queue_name,
          :sqs_queue_url => queue_url,
          :message_text => "AWS SQS queue #{queue_name} URL found"
        }))

        @poller = Aws::SQS::QueuePoller.new(queue_url)

        @wait_time_seconds = 10  # shouldn't we use the config for this?
      rescue Aws::SQS::Errors::NonExistentQueue, Seahorse::Client::NetworkingError => e
        raise PipefyMessage::Providers::Errors::ResourceError, e.message
      end

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

      # Initiates SQS queue polling, with wait_time_seconds as given in
      # the initial configuration.
      def poller
        logger.debug(JSON.dump({
          :message_text => "Initiating SQS polling..."
        }))

        @poller.poll(wait_time_seconds: @config[:wait_time_seconds]) do |received_message|
          logger.debug(JSON.dump({
            :message_text => "Message received by SQS poller"
          }))
          payload = JSON.parse(received_message.body)
          yield(payload)
        end
      end

      private

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
