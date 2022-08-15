# frozen_string_literal: true

require "benchmark"
require_relative "providers/errors"
require_relative "providers/broker_resolver"

module PipefyMessage
  ##
  # Provides a provider-agnostic, higher level abstraction for
  # dealing with queue polling and message parsing.
  # Should be included by classes that implement a perform method, for
  # processing received messages.
  module Consumer
    include PipefyMessage::Logging
    include PipefyMessage::Providers::Errors
    include PipefyMessage::Providers::BrokerResolver

    ##
    # Default options for consumer setup.
    def self.default_consumer_options
      @default_consumer_options ||= {
        broker: "aws"
      }
    end

    ##
    # Makes methods available as a static/class methods
    # (see ClassMethods).
    def self.included(base)
      base.extend(self)
      base.extend(ClassMethods)
    end

    ##
    # To be defined by classes that include this module. Processes
    # messages received by the poller. Called by process_message from
    # an instance of the including class.
    def perform(_message, _metadata)
      error_msg = includer_should_implement(__method__)
      raise NotImplementedError, error_msg
    end

    ##
    # Encapsulates methods to be included as class/static
    # (rather than instance) attributes and methods.
    module ClassMethods
      ##
      # Merges default worker options with the hash passed as
      # an argument. The latter takes precedence.
      def options(opts = {})
        @consumer_options = Consumer.default_consumer_options.merge(opts)
      end

      ##
      # Initializes and returns an instance of a broker for
      # the provider specified in the class options.
      def build_consumer_instance
        consumer_map = resolve_broker(@consumer_options[:broker], "consumer")
        consumer_map[:class_name].constantize.new(@consumer_options)
      end

      ##
      # Instantiates a broker object (see build_consumer_instance method),
      # polls the queue given in the options and forwards received
      # messages for processing by a newly created instance of the class
      # from which the call to process_message was made (see perform
      # method in the parent module).
      def process_message
        obj = new

        logger.info({ log_text: "Calling consumer poller" })

        build_consumer_instance.poller do |payload, metadata|
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)

          context = metadata[:context]
          correlation_id = metadata[:correlationId]
          event_id = metadata[:eventId]

          logger.info(log_context({
                                    log_text: "Message received by poller to be processed by consumer",
                                    received_message: payload,
                                    metadata: metadata
                                  }, context, correlation_id, event_id))

          retry_count = metadata["ApproximateReceiveCount"].to_i - 1
          obj.perform(payload,
                      { retry_count: retry_count, context: context, correlation_id: correlation_id })

          elapsed_time_ms = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond) - start
          logger.info(log_context({
                                    duration_ms: elapsed_time_ms,
                                    log_text: "Message received by consumer poller, processed " \
                                              "in #{elapsed_time_ms} milliseconds"
                                  }, context, correlation_id, event_id))
        end
      rescue PipefyMessage::Providers::Errors::ResourceError => e
        context = "NO_CONTEXT_RETRIEVED" unless defined? context
        correlation_id = "NO_CID_RETRIEVED" unless defined? correlation_id
        event_id = "NO_EVENT_ID_RETRIEVED" unless defined? event_id
        # this shows up in multiple places; OK or DRY up?

        logger.error(log_context({
                                   log_text: "Failed to process message; details: #{e.inspect}"
                                 }, context, correlation_id, event_id))
        raise e
      end
    end
  end
end
