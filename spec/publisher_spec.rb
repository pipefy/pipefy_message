# frozen_string_literal: true

require_relative "../lib/pipefy_message/providers/aws_client/sns_broker"

RSpec.describe PipefyMessage::Publisher do
  context "when I try to publish a message to SNS broker" do
    before do
      ENV["AWS_ENDPOINT"] = "http://localhost:4566"
      ENV["AWS_ACCESS_KEY_ID"] = "foo"
      ENV["AWS_SECRET_ACCESS_KEY"] = "bar"
      ENV["ENABLE_AWS_CLIENT_CONFIG"] = "true"
      ENV["AWS_CLI_STUB_RESPONSE"] = "true"
    end
    it "should publish a message properly" do
      mocked_publisher_impl = PipefyMessage::Providers::AwsClient::SnsBroker.new
      mocked_return = { message_id: "5482c8be-db2c-44ec-a899-3aa52e424cc3",
                        sequence_number: nil }

      allow(mocked_publisher_impl).to receive(:publish).and_return(mocked_return)

      allow_any_instance_of(PipefyMessage::Publisher)
        .to receive(:publisher_instance)
        .and_return(mocked_publisher_impl)

      publisher = PipefyMessage::Publisher.new

      payload = { foo: "bar" }
      topic_name = "pipefy-local-topic"
      result = publisher.publish(payload, topic_name)
      expect(result).to eq mocked_return
      expect(mocked_publisher_impl).to have_received(:publish).with(payload, topic_name)
    end

    # it "should choose the correct broker implementation" do
    #   result = PipefyMessage::Publisher::BasePublisher.new.send(:publisher_instance)
    #   expected_impl = PipefyMessage::Publisher::AwsProvider::SnsPublisher

    #   expect(result).to be_a expected_impl
    # end
  end
end
