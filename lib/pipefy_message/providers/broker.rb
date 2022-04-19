module PipefyMessage
  module Providers
    # Provides a provider-agnostic, higher level abstraction for
    # objects that provide pollers. Should be included in classes implemented for specific providers. Used by the Worker module.
    class Broker
      include PipefyMessage::Logging

      def poller
        raise NotImplementedError, "Method #{__method__} should be implemented by classes including #{method(__method__).owner}"
      end

      def default_options
        {}
      end
    end
  end
end
