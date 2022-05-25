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
    def perform(_message)
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
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        obj = new

        logger.info({ message_text: "Calling consumer poller" })

        build_consumer_instance.poller do |payload|
          logger.info({
                        message_text: "Message received by poller to be processed by consumer",
                        received_message: payload
                      })

          obj.perform(payload["Message"])

          elapsed_time_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000
          logger.info({
                        duration_ms: elapsed_time_ms,
                        message_text: "Message received by consumer poller, processed " \
                                      "in #{elapsed_time} milliseconds"
                      })
        end
      rescue PipefyMessage::Providers::Errors::ResourceError => e
        logger.error("Failed to process message, details #{e.inspect}")
        raise e
      end
    end
  end
end
