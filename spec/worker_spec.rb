# frozen_string_literal: true

RSpec.describe PipefyMessage::Worker do
  $result =~ nil

  # class MockBroker < Broker
  #   def poller
  #     yield("test")
  #   end
  # end
  
  class TestWorker
    include PipefyMessage::Worker
    pipefymessage_options broker: "aws"

    def perform(message)
      $result = message
    end
  end

  describe "#perform" do

    #mock PipefyMessage::Providers::AwsBroker -> MockBroker

    it "allow call .perform from instance worker when call perform_async from ClassMethod" do
      TestWorker.perform_async
      expect($result).to eq "test"
    end
  end

  describe "#options class" do
    it "should set options in class" do
      expect(TestWorker.broker).to eq "aws"
    end
  end

  
end
