# frozen_string_literal: true

require_relative "../../lib/pipefy_message/providers/aws_broker"

RSpec.describe PipefyMessage::Providers::AwsBroker do
  context "#AwsBroker" do
    before do
      stub_const("ENV", ENV.to_hash.merge("AWS_CLI_STUB_RESPONSE" => "true"))
    end
    describe "should raise Errors" do
      it "QueueNonExistError" do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:get_queue_url)
          .with({ queue_name: "my_queue" })
          .and_raise(
            Aws::SQS::Errors::NonExistentQueue.new(
              double(Aws::SQS::Client),
              "The specified queue my_queue does not exist for this wsdl version"
            )
          )

        expect do
          PipefyMessage::Providers::AwsBroker.new("my_queue")
        end.to raise_error(PipefyMessage::Providers::Errors::ResourceError,
                           /The specified queue my_queue does not exist for this wsdl version/)
      end
    end
  end
end
