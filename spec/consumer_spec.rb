# frozen_string_literal: true

class MockBroker
  def poller; end
end

class MockBrokerFail
  def poller
    raise PipefyMessage::Providers::Errors::ResourceError
  end
end

class TestConsumer
  include PipefyMessage::Consumer
  options broker: "aws", queue_name: "pipefy-local-queue"

  def perform(message)
    puts message
  end
end

RSpec.describe PipefyMessage::Consumer do
  before do
    ENV["ENABLE_AWS_CLIENT_CONFIG"] = "true"
    ENV["AWS_CLI_STUB_RESPONSE"] = "true"
  end
  describe "#perform" do
    context "successful polling" do
      it "should call #perform from child instance when #process_message is called" do
        mock_broker = instance_double("MockBroker")
        allow(mock_broker).to receive(:poller).with(no_args)

        allow(TestConsumer).to receive(:build_consumer_instance).and_return(mock_broker)

        TestConsumer.process_message
        expect(mock_broker).to have_received(:poller)
      end
    end

    context "polling failure" do
      it "should call #perform from child instance when #process_message is called" do
        allow(TestConsumer).to receive(:build_consumer_instance).and_return(MockBrokerFail.new)
        expect { TestConsumer.process_message }.to raise_error(PipefyMessage::Providers::Errors::ResourceError)
      end
    end

    it "should fail if called directly from the parent class" do
      expect { TestConsumer.perform("message") }.to raise_error NotImplementedError
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
