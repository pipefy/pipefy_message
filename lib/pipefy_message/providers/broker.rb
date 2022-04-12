module PipefyMessage
    module Providers
        class Broker
            def poller()
                raise NotImplementedError
            end
        end 
    end
end