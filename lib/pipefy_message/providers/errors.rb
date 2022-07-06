# frozen_string_literal: true

module PipefyMessage
  module Providers
    ##
    # Provides higher-level error classes that can be used for
    # handling similar errors thrown by different providers, as well
    # as common error messages.
    module Errors
      ##
      # Enables automatic error logging when prepended to a custom error
      # class.
      #
      # In order for this module to work, the prepending class must
      # inherit from the Ruby Exception class. Note that this condition
      # is satisfied by any custom error class that inherits from
      # StandardError and its children, such as RuntimeError, given that
      # StandardError is itself a child of Exception.
      #
      # The reason to use prepend rather than include is to make this
      # module come below the error class in the inheritance chain.
      # This ensures that, when an error is raised and its constructor
      # is called, this module's initialize method gets called first,
      # then calls the original constructor with super, and calls the
      # logger once initialization is done. This effectively "wraps"
      # the error initialize method in the logging constructor below.
      module LoggingError
        prepend PipefyMessage::Logging

        def initialize(msg = nil)
          super
          logger.error({
                         error_class: self.class,
                         error_message: message,
                         stack_trace: full_message
                       })

          # message and full_message are methods provided by the
          # Ruby Exception class.
          # The hash keys used above were an attempt to provide more
          # descriptive names than those of the original methods (:P),
          # but this has still led to some confusion, so, to be more
          # explicit: if e is an instance of Exception (or its
          # children), e.message returns the error message for e and
          # e.full_message provides the full stack trace. This is
          # what's being included in the logs above. Logging inside
          # the constructor ensures information is logged as soon
          # as the error is raised.
          # For details, please refer to the official documentation for
          # the Exception class.
        end
      end

      ##
      # Abstraction for service and networking errors.
      class ResourceError < RuntimeError
        prepend PipefyMessage::Providers::Errors::LoggingError
      end

      ##
      # To be raised when an invalid value is passed as an option
      # to a method call (eg: if a queueing service client is
      # initialized with an invalid queue identifier).
      class InvalidOption < ArgumentError
        prepend PipefyMessage::Providers::Errors::LoggingError
      end

      # Error messages:
      # (Should these be moved outside the providers directory?)

      ##
      # To be used when raising NotImplementedError from an "abstract"
      # method in a superclass.
      def includer_should_implement(meth)
        "Method #{meth} should be implemented by classes including #{method(meth).owner}"
      end
    end
  end
end
