# frozen_string_literal: true

require_relative "../../../lib/pipefy_message/providers/aws_client/sns_broker"

RSpec.describe PipefyMessage::Providers::AwsClient::SnsBroker do
  context "when I try to publish a message with Sns publisher" do
    before(:each) do
      stub_const("ENV", ENV.to_hash.merge("AWS_ENDPOINT" => "http://localhost:4566"))
      stub_const("ENV", ENV.to_hash.merge("AWS_CLI_STUB_RESPONSE" => "true"))
    end
    it "should return a message ID" do
      @publisher = PipefyMessage::Providers::AwsClient::SnsBroker.new
      mocked_return = { message_id: "5482c8be-db2c-44ec-a899-3aa52e424cc3",
                        sequence_number: nil }

      allow(@publisher).to receive(:publish).and_return(mocked_return)

      payload = { foo: "bar" }
      result = @publisher.publish(payload, "pipefy-local-topic")
      expect(result).to eq mocked_return
    end
  end
end
