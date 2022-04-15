module PipefyMessage
  module Providers
    class Broker
      def poller
        raise NotImplementedError
      end

      def default_options
        {}
      end
    end
  end
end
