# frozen_string_literal: true

require "aws-sdk-core"
require "pipefy_message/providers/aws_client/sqs_broker"

class MockBrokerFail
  def poller
    raise PipefyMessage::Providers::Errors::ResourceError
  end
end

class TestConsumer
  include PipefyMessage::Consumer
  options broker: "aws", queue_name: "pipefy-local-queue"

  def perform(message, metadata)
    puts "#{message} - #{metadata}"
  end
end

class MockTestConsumerFail
  include PipefyMessage::Consumer
  options broker: "aws", queue_name: "pipefy-local-queue"

  def perform(message, metadata)
    puts "#{message} - #{metadata}"
    throw StandardError
  end
end

RSpec.describe PipefyMessage::Consumer do
  before do
    ENV["ENABLE_AWS_CLIENT_CONFIG"] = "true"
    ENV["AWS_CLI_STUB_RESPONSE"] = "true"

    Aws.config[:sqs] = {
      stub_responses: {
        receive_message: [
          { messages: [{ message_id: "950b674b-0e9f-4336-8a32-7502dbf2eb36",
                         receipt_handle: "950b674b-0e9f-4336-8a32-7502dbf2eb36", body: { foo: "bar" }.to_json,
                         attributes: { "ApproximateReceiveCount" => "1" } }] }
        ],
        get_queue_url: [
          { queue_url: "http://localhost" }
        ]
      }
    }
  end
  after do
    Aws.config = {} # undoing changes
    # (to avoid test "cross-contamination")
  end
  describe "#perform" do
    context "successful polling with SQS Broker" do
      it "should call #perform from child instance when #process_message is called" do
        sqs_mock_broker = PipefyMessage::Providers::AwsClient::SqsBroker.new({ queue_name: "pipefy-local-queue" })
        poller = sqs_mock_broker.instance_variable_get(:@poller)
        poller.before_request do |stats|
          throw :stop_polling if stats.received_message_count >= 1
        end

        allow(TestConsumer).to receive(:build_consumer_instance).and_return(sqs_mock_broker)

        TestConsumer.process_message
      end
    end

    context "continue polling after failure with SQS broker" do
      it "should continue calling #perform after any failure" do
        sqs_mock_broker = PipefyMessage::Providers::AwsClient::SqsBroker.new({ queue_name: "pipefy-local-queue" })
        poller = sqs_mock_broker.instance_variable_get(:@poller)
        received_message_counter = 0

        poller.before_request do |stats|
          received_message_counter = stats.received_message_count
          throw :stop_polling if stats.received_message_count == 2
        end

        allow(MockTestConsumerFail).to receive(:build_consumer_instance).and_return(sqs_mock_broker)

        MockTestConsumerFail.process_message
        expect(received_message_counter).to be == 2
      end
    end

    context "polling failure" do
      it "should call #perform from child instance when #process_message is called" do
        allow(TestConsumer).to receive(:build_consumer_instance).and_return(MockBrokerFail.new)
        expect { TestConsumer.process_message }.to raise_error(PipefyMessage::Providers::Errors::ResourceError)
      end
    end

    it "should fail if called directly from the parent class" do
      expect { TestConsumer.perform("message", {}) }.to raise_error NotImplementedError
    end
  end

  describe "#options class" do
    it "should set options in class" do
      expect(TestConsumer.options[:broker]).to eq "aws"
    end
  end

  describe "#build_instance_broker" do
    context "invalid provider" do
      before(:all) do
        TestConsumer.options[:broker] = "NaN"
      end

      after(:all) do
        TestConsumer.options[:broker] = "aws" # reverting
      end

      it "should raise an error" do
        expect { TestConsumer.build_consumer_instance }.to raise_error PipefyMessage::Providers::Errors::InvalidOption
      end
    end

    # context "valid provider" do
    #   it "should instantiate a consumer for the given queue" do
    #     # (I'd like to test that it does create an instance while
    #     # passing the correct queue and options as args, in a way
    #     # that doesn't rely on any specific provider implementation
    #     # so as not to make this an integration test, but I can't
    #     # even figure out how to do this atm lol This is rather
    #     # coupled :P)
    #   end
    # end
  end
end
