module PipefyMessage
    module Providers
        module Errors
            class ResourceError < StandardError
                def initialize(msg="ResourceError")
                    super
                  end
            end
        end
    end
end