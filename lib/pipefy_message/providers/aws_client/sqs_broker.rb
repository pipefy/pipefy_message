# frozen_string_literal: true

require_relative "aws_client"

module PipefyMessage
  module Providers
    module AwsClient
      ##
      # AWS SQS client.
      class SqsBroker
        include PipefyMessage::Logging
        include PipefyMessage::Providers::Errors

        def initialize(opts = {})
          @config = default_options.merge(opts)

          AwsClient.aws_setup

          @sqs = Aws::SQS::Client.new

          @is_staging = ENV["ASYNC_APP_ENV"] == "staging"

          @queue_url = handle_queue_protocol(@sqs.get_queue_url({ queue_name: handle_queue_name(@config[:queue_name]) })
                                                 .queue_url)

          @poller = Aws::SQS::QueuePoller.new(@queue_url, { client: @sqs })

          logger.debug({
                         queue_url: @queue_url,
                         message_text: "SQS client created"
                       })
        rescue StandardError => e
          raise PipefyMessage::Providers::Errors::ResourceError, e.message
        end

        ##
        # Initiates SQS queue polling, with wait_time_seconds as given
        # in the initial configuration.
        def poller
          logger.info(merge_log_hash({
                                       message_text: "Initiating SQS polling on queue #{@queue_url}"
                                     }))

          @poller.poll({ wait_time_seconds: @config[:wait_time_seconds],
                         message_attribute_names: ["All"], attribute_names: ["All"] }) do |received_message|
            metadata, payload = extract_metadata_and_payload(received_message)
            context = metadata[:context]
            correlation_id = metadata[:correlationId]
            event_id = metadata[:eventId]
            # We're extracting those again in the consumer
            # process_message module. I considered whether these
            # should perhaps be `yield`ed instead, but I guess
            # this is not the bad kind of repetition.

            logger.debug(
              merge_log_hash(log_context({
                                           message_text: "Message received by SQS poller"
                                         }, context, correlation_id, event_id))
            )
            yield(payload, metadata)
          rescue StandardError => e
            # error in the routine, skip delete to try the message again later with 30sec of delay

            context = "NO_CONTEXT_RETRIEVED" unless defined? context
            correlation_id = "NO_CID_RETRIEVED" unless defined? correlation_id
            event_id = "NO_EVENT_ID_RETRIEVED" unless defined? event_id
            # this shows up in multiple places; OK or DRY up?

            logger.error(
              merge_log_hash(log_context({
                                           queue_url: @queue_url,
                                           message_text: "Failed to consume message; details: #{e.inspect}"
                                         }, context, correlation_id, event_id))
            )

            throw e if e.instance_of?(NameError)

            throw :skip_delete
          end
        end

        private

        ##
        # Extends AWS default options to include a value
        # for SQS-specific configurations.
        def default_options
          { wait_time_seconds: 10, queue_name: "pipefy-local-queue" }
        end

        ##
        # Adds the queue name to logs, if not already present.
        def merge_log_hash(log_hash)
          { queue_name: @config[:queue_name] }.merge(log_hash)
        end

        ##
        # Adds the staging suffix to queue names where applicable.
        def handle_queue_name(queue_name)
          @is_staging ? "#{queue_name}-staging" : queue_name
        end

        def handle_queue_protocol(queue_url)
          ENV["ASYNC_APP_ENV"] == "development" ? queue_url : queue_url.sub(%r{^http://}, "https://")
        end

        ##
        # Extracts metadata value according to its type
        def extract_metadata_value(metadata, key, body_message_attribute_field)
          value_from_metadata = if !metadata.empty? && metadata.key?(key)
                                  case metadata[key].data_type
                                  when "String"
                                    metadata[key].string_value
                                  when "Binary"
                                    metadata[key].binary_value
                                  end
                                end

          value_from_metadata.nil? ? body_message_attribute_field.dig(key, "Value") : value_from_metadata
        end

        ##
        # Transform metadata and payload to a simple hash
        # Also handle differences if `Enable raw message delivery` SQS setting is on/off
        def extract_metadata_and_payload(received_message)
          original_metadata = received_message.message_attributes.merge(received_message.attributes)
          body_as_json = JSON.parse(received_message.body)

          body_message_attribute_field_normalized = body_as_json["MessageAttributes"] || {}
          context = extract_metadata_value(original_metadata, "context", body_message_attribute_field_normalized)
          correlation_id = extract_metadata_value(original_metadata, "correlationId", body_message_attribute_field_normalized)
          event_id = extract_metadata_value(original_metadata, "eventId", body_message_attribute_field_normalized)
          payload = body_as_json["Message"] || received_message.body

          [
            {
              context: context,
              correlationId: correlation_id,
              eventId: event_id
            },
            payload
          ]
        end
      end
    end
  end
end
