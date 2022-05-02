# frozen_string_literal: true

$result =~ nil

class MockBroker
  def poller
    yield("test")
  end
end

class MockBrokerFail
  def poller
    raise PipefyMessage::Providers::Errors::ResourceError
  end
end

class TestWorker
  include PipefyMessage::Worker
  pipefymessage_options broker: "aws", queue_name: "pipefy-local-queue"

  def perform(message)
    puts message
    $result = message
  end
end

RSpec.describe PipefyMessage::Worker do
  describe "#perform" do
    context "successful polling" do
      it "should call #perform from child instance when #process_message is called" do
        allow(TestWorker).to receive(:build_instance_broker).and_return(MockBroker.new)

        TestWorker.process_message
        expect($result).to eq "test"
      end
    end

    context "polling failure" do
      it "should call #perform from child instance when #process_message is called" do
        allow(TestWorker).to receive(:build_instance_broker).and_return(MockBrokerFail.new)
        expect { TestWorker.process_message }.to raise_error(PipefyMessage::Providers::Errors::ResourceError)
      end
    end

    it "should fail if called directly from the parent class" do
      expect { TestWorker.perform("message") }.to raise_error NotImplementedError
    end
  end

  describe "#options class" do
    it "should set options in class" do
      expect(TestWorker.broker).to eq "aws"
    end
  end

  describe "#build_instance_broker" do
    context "invalid provider" do
      before(:all) do
        TestWorker.broker = "NaN"
      end

      after(:all) do
        TestWorker.broker = "aws" # reverting
      end

      it "should raise an error" do
        expect { TestWorker.build_instance_broker }.to raise_error PipefyMessage::Providers::Errors::InvalidOption
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
