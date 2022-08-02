# frozen_string_literal: true

require_relative "../lib/pipefy_message/providers/aws_client/sns_broker"

class TestBroker
  def publish(message, topic, context, correlation_id, event_id); end
end

RSpec.describe PipefyMessage::Publisher do
  let(:payload) { { foo: "bar" } }
  let(:topic_name) { "pipefy-local-topic" }
  let(:context) { "NO_CONTEXT_PROVIDED" }
  let(:cid) { "NO_CID_PROVIDED" }
  let(:event_id) { "15075c9d-7337-4f70-be02-2732aff2c2f7" }

  let(:call_publish) do
    subject.publish(
      payload,
      topic_name,
      context,
      cid
    )
  end

  it "forwards the message to be published by an instance" do
    test_broker = instance_double("TestBroker")
    allow(test_broker).to receive(:publish)

    allow_any_instance_of(described_class)
      .to receive(:build_publisher_instance)
      .and_return(test_broker)

    allow(SecureRandom).to receive(:uuid).and_return("15075c9d-7337-4f70-be02-2732aff2c2f7")

    call_publish

    expect(test_broker).to have_received(:publish).with(payload, topic_name, context, cid, event_id)
  end

  context "when I try to publish a message to SNS broker" do
    before do
      changed_opts = {
        "AWS_ENDPOINT" => "http://localhost:4566",
        "AWS_ACCESS_KEY_ID" => "foo",
        "AWS_SECRET_ACCESS_KEY" => "bar",
        "ENABLE_AWS_CLIENT_CONFIG" => "true",
        "AWS_CLI_STUB_RESPONSE" => "true"
      }

      stub_const("ENV", ENV.to_hash.merge(changed_opts))
    end
    it "should choose the correct broker implementation" do
      result = described_class.new.send(:build_publisher_instance)
      expected_impl = PipefyMessage::Providers::AwsClient::SnsBroker

      expect(result).to be_a expected_impl
    end

    it "should publish a message properly" do
      mocked_publisher_impl = PipefyMessage::Providers::AwsClient::SnsBroker.new
      mocked_return = { message_id: "5482c8be-db2c-44ec-a899-3aa52e424cc3",
                        sequence_number: nil }

      allow(mocked_publisher_impl).to receive(:publish).and_return(mocked_return)

      allow_any_instance_of(described_class)
        .to receive(:build_publisher_instance)
        .and_return(mocked_publisher_impl)

      allow(SecureRandom).to receive(:uuid).and_return("15075c9d-7337-4f70-be02-2732aff2c2f7")

      result = call_publish
      expect(result).to eq mocked_return
      expect(mocked_publisher_impl).to have_received(:publish).with(payload, topic_name, context, cid, event_id)
    end
  end
end
