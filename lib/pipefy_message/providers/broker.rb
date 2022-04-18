module PipefyMessage
  module Providers
    class Broker
      include PipefyMessage::Logging

      def poller
        raise NotImplementedError
      end

      def default_options
        {}
      end
    end
  end
end
