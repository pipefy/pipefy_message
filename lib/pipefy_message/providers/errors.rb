# frozen_string_literal: true

module PipefyMessage
  module Providers
    ##
    # Provides higher-level error classes that can be used for
    # handling similar errors thrown by different providers, as well
    # as common error messages.
    module Errors

      ##
      # When included in an Exception class, automatically logs every
      # time an instance is raised.
      module LoggingError
        prepend PipefyMessage::Logging

        def initialize(msg = nil)
          super
          logger.error({
                         error_class: self.class,
                         error_message: message,
                         stack_trace: full_message
                       })
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
