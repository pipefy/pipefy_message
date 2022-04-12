require "aws-sdk-sqs"
require "json"

module PipefyMessage
    module Providers
        class AwsBroker < Broker
            def initialize(queue_url)
                @poller = Aws::SQS::QueuePoller.new(queue_url)
                @wait_time_seconds = 10
            end

            def poller()
                ## Aws poller 
                @poller.poll(wait_time_seconds: @wait_time_seconds) do |received_message|
                    payload = JSON.parse(received_message.body)
                    yield(payload)
                end
            end
        end
    end
end