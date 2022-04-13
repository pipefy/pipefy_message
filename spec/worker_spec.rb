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
      raise Exception.new "This is an exception"
    end
  end
  
  class TestWorker
    include PipefyMessage::Worker
    pipefymessage_options broker: "aws"

    def perform(message)
      $result = message
    end
  end

  describe "#perform" do
    it "should call #perform from child instance when call #perform_async with success" do
      allow(TestWorker).to receive(:build_instance_broker).and_return(MockBroker.new)
      
      TestWorker.perform_async
      expect($result).to eq "test"
    end

    it "should call #perform from child instance when call #perform_async with fail(raise a exception)" do
      allow(TestWorker).to receive(:build_instance_broker).and_return(MockBrokerFail.new)
      expect{ TestWorker.perform_async }.to raise_error
    end
  end

  describe "#options class" do
    it "should set options in class" do
      expect(TestWorker.broker).to eq "aws"
    end
  end

  
end
