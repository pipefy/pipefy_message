# frozen_string_literal: true

module PipefyMessage
  module Worker
    # ClassMethods
    module ClassMethods #ActiveJob
      def perform(body, options = {}); end
      def pipefymessages_options(opts = {}); end
    end
  end
end
