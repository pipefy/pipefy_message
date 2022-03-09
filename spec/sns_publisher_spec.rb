# frozen_string_literal: true

RSpec.describe PipefyMessage::Publisher::AwsProvider::SnsPublisher do
  context "when I try to publish a message with Sns publisher" do
    before(:each) do
      ENV["AWS_ENDPOINT"] = "http://localhost:4566"
      ENV["AWS_ACCESS_KEY_ID"] = "foo"
      ENV["AWS_SECRET_ACCESS_KEY"] = "bar"

      @publisher = PipefyMessage::Publisher::AwsProvider::SnsPublisher.new
    end
    it "should return a message ID" do
      mocked_return = { message_id: "5482c8be-db2c-44ec-a899-3aa52e424cc3",
                        sequence_number: nil }

      allow(@publisher).to receive(:do_publish).and_return(mocked_return)

      payload = { foo: "bar" }
      result = @publisher.publish(payload, "arn:aws:sns:us-east-1:000000000000:pipefy-local-topic")
      expect(result).to eq mocked_return
    end
    it "should prepare the payload" do
      payload = { foo: "bar", bar: "foo" }
      prepared_payload = @publisher.send(:prepare_payload, payload)

      expected_payload = { "default" => { bar: "foo", foo: "bar" } }

      expect(prepared_payload).to eq(expected_payload)
    end
  end
end
