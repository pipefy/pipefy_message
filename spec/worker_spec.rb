# frozen_string_literal: true

RSpec.describe PipefyMessage::Worker do
  $result =~ nil

  class MockBroker < PipefyMessage::Providers::Broker
    def poller
      yield("test")
    end
  end

  class MockBrokerFail < PipefyMessage::Providers::Broker
    def poller
      raise PipefyMessage::Providers::Errors::ResourceError
    end
  end

  class TestWorker
    include PipefyMessage::Worker
    pipefymessage_options broker: "sqs", queue_name: "pipefy-local-queue"

    def perform(message)
      puts message
      $result = message
    end
  end

  describe "#perform" do
    it "should call #perform from child instance when call #process_message with success" do
      allow(TestWorker).to receive(:build_instance_broker).and_return(MockBroker.new)

      TestWorker.process_message
      expect($result).to eq "test"
    end

    it "should call #perform from child instance when call #process_message with fail(raise a ResourceError)" do
      allow(TestWorker).to receive(:build_instance_broker).and_return(MockBrokerFail.new)
      expect { TestWorker.process_message }.to raise_error(PipefyMessage::Providers::Errors::ResourceError)
    end
  end

  describe "#options class" do
    it "should set options in class" do
      expect(TestWorker.broker).to eq "sqs"
    end
  end
end
