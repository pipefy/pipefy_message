# frozen_string_literal: true

require_relative "../../lib/pipefy_message/providers/aws_broker"

RSpec.describe PipefyMessage::Providers::AwsBroker do
  context "#AwsBroker" do
    before do
      ENV["AWS_CLI_STUB_RESPONSE"] = "true"
    end

    describe "should raise Errors" do
      it "QueueNonExistError" do
        expect do
          PipefyMessage::Providers::AwsBroker.new("my_queue")
        end.to raise_error(PipefyMessage::Providers::Errors::ResourceError,
                           /The specified queue my_queue does not exist for this wsdl version/)
      end
    end
  end
end
