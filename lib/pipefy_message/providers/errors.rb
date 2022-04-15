# frozen_string_literal: true
module PipefyMessage
  module Providers
    module Errors
      class ResourceError < RuntimeError
        def initialize(msg = "ResourceError")
          super
        end
      end
    end
  end
end
