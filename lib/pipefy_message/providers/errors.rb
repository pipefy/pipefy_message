# frozen_string_literal: true

module PipefyMessage
  module Providers
    ##
    # Provides higher-level error classes that can be used for
    # handling similar errors thrown by different providers, as well
    # as common error messages.
    module Errors
      ##
      # Abstraction for service and networking errors.
      class ResourceError < RuntimeError
      end

      ##
      # Abstraction for errors caused by nonexisting queues, such as
      # Aws::SQS::Errors::QueueDoesNotExist.
      class QueueDoesNotExist < ResourceError
        def initialize(msg = "The specified queue does not exist")
          super
        end
      end

      ##
      # Abstraction for provider authorization errors, such as
      # Aws::SNS::Errors::AuthorizationError.
      class AuthorizationError < RuntimeError
      end

      ##
      # To be raised when an invalid value is passed as an option
      # to a method call (eg: if a queueing service client is
      # initialized with an invalid queue identifier).
      class InvalidOption < ArgumentError
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
