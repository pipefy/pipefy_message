# frozen_string_literal: true

RSpec.describe PipefyMessage::Worker do
  $result =~ nil
  
  class TestWorker
    include PipefyMessage::Worker
    pipefymessage_options broker: "aws"

    def perform(body)
      $result = body
    end
  end

  describe "#perform" do
    it "allow call .perform" do
      worker = TestWorker.new
      worker.perform("test")
      expect($result).to eq "test"
    end
  end

  describe "#options class" do
    it "should set options in class" do
      TestWorker.new
      expect(TestWorker.broker).to eq "aws"
    end
  end
end
