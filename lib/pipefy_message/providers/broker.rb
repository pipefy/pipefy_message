# frozen_string_literal: true

module PipefyMessage
  module Providers
    # Provides a provider-agnostic, higher level abstraction for
    # objects that provide pollers. Should be included in classes
    # implemented for specific providers. Used by the Worker module.
    class Broker
      include PipefyMessage::Logging
      include PipefyMessage::Providers::Errors

      def poller
        error_msg = includer_should_implement(__method__)
        raise NotImplementedError, error_msg
      end

      def publish(_payload, _topic_name)
        error_msg = includer_should_implement(__method__)
        raise NotImplementedError, error_msg
      end

      def default_options
        {}
      end
    end
  end
end
