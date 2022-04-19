# frozen_string_literal: true

require "singleton"
require "benchmark"

module PipefyMessage
  ##
  # Provides a provider-agnostic, higher level abstraction for
  # dealing with queue polling and message parsing.
  # Should be included by classes hat implement a perform method, for
  # processing received messages.
  module Worker
    include PipefyMessage::Logging
    ##
    # default values to consumer
    def self.default_worker_options
      @default_worker_options ||= {
        "broker" => "aws",
        "queue_name" => "my_queue"
      }
    end

    ##
    # to make the logger available as a static method
    # see ClassMethods; this is what makes
    # those methods available to the base class
    def self.included(base)
      base.extend(self)
      base.extend(ClassMethods)
    end

    ##
    # To be defined by classes that include this module. Processes
    # messages received by the poller. Called by process_message from
    # an instance of the including class.
    def perform(_message)
      raise NotImplementedError,
            "Method #{__method__} should be implemented by classes including #{method(__method__).owner}"
    end

    ##
    # Encapsulates methods to be included as class/static
    # (rather than instance) attributes and methods.
    module ClassMethods
      ##
      # Merges default worker options with the hash passed as
      # an argument. The latter takes precedence.
      def pipefymessage_options(opts = {})
        @options_hash = Worker.default_worker_options.merge(opts.transform_keys(&:to_s))
        @options_hash.each do |k, v|
          singleton_class.class_eval { attr_accessor k }
          send("#{k}=", v)
        end

        logger.debug({
                       options_set: @options_hash,
                       message_text: "Set #{name} options to options_set"
                     })
      end

      ##
      # Initializes and returns an instance of a broker for
      # the provider specified in the class options.
      def build_instance_broker
        map = { "aws" => "PipefyMessage::Providers::AwsBroker" }
        require_relative "providers/#{broker}_broker"

        logger.info({
                      broker: broker,
                      message_text: "Initializing and returning instance of #{broker} broker"
                    })

        map[broker].constantize.new(queue_name, @options_hash)
      end

      # Instantiates a broker object (see build_instance_broker method),
      # polls the queue given in the options and forwards received
      # messages for processing by a newly created instance of the class
      # from which the call to process_message was made (see perform
      # method in the parent module).
      def process_message
        obj = new

        logger.info({
                      broker: broker,
                      message_text: "Calling poller for #{broker} object"
                    })

        build_instance_broker.poller do |message|
          logger.info({
                        broker: broker,
                        message_text: "Message received by #{broker} poller to be processed by worker",
                        received_message: message # necessary? TMI?
                      })

          elapsed_time = Benchmark.realtime do
            # what would the best measurement be?
            obj.perform(message)
          end

          logger.info({
                        duration_seconds: elapsed_time,
                        message_text: "Message received by #{broker} poller processed by #{name} worker in #{elapsed_time} seconds"
                      })
        end
      rescue Exception => e
        # TODO: Implement retry
        raise e
      end
    end
  end
end
