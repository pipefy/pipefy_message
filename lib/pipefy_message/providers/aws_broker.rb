require "aws-sdk-sqs"
require "json"

module PipefyMessage
    module Providers
        class AwsBroker < Broker

            @@default_options = { 
                access_key_id:  (ENV["AWS_ACCESS_KEY_ID"] || "foo"),
                secret_access_key: (ENV["AWS_SECRET_ACCESS_KEY"] || "bar"),
                endpoint:  (ENV["AWS_ENDPOINT"] || "http://localhost:4566"),
                region:  (ENV["AWS_REGION"] || "us-east-1"),
                stub_responses: (ENV["AWS_CLI_STUB_RESPONSE"] || "true")
            }

            def initialize(queue_url)

                @config = AwsBroker.config_options
                
                Aws.config.update(@config)

                
                @sqs = Aws::SQS::Client.new(region: @config[:region])                
                require "pry"; binding.pry

                @poller = Aws::SQS::QueuePoller.new(queue_url)
                @poller.before_request { stop! if user_interrupt == true }
                @wait_time_seconds = 10
            end

            def self.config_options
                @@default_options
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