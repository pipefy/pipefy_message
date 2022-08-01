# frozen_string_literal: true

require_relative "../../../lib/pipefy_message/providers/aws_client/sns_broker"
require_relative "aws_stub_context"

RSpec.describe PipefyMessage::Providers::AwsClient::SnsBroker do
  describe "#initialize" do
    let(:prefix) { "test" }
    let(:env_prefix) { "env" }

    it "should have a default ARN prefix" do
      sns_broker = described_class.new

      expect(sns_broker.instance_variable_get(:@topic_arn_prefix)).to_not eq nil
    end

    it "should set a nondefault ARN prefix from an env var" do
      stub_const("ENV", ENV.to_hash.merge({ "AWS_SNS_ARN_PREFIX" => env_prefix }))

      sns_broker = described_class.new

      expect(sns_broker.instance_variable_get(:@topic_arn_prefix)).to eq env_prefix
    end
  end

  describe "#publish" do
    include_context "AWS stub"

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
        cid,
        event_id
      )
    end

    it "should return a message ID and a sequence number" do
      result = call_publish

      # AWS default stub values:
      expect(result.message_id).to eq "messageId"
      expect(result.sequence_number).to eq "String"
    end

    it "should receive payload with expected message attributes" do
      sns_client_mock = spy(Aws::SNS::Resource.new)
      sns_topic_mock = spy(Aws::SNS::Topic.new(arn: "foo", client: Aws::SNS::Client.new({})))
      allow(sns_client_mock).to receive(:topic).and_return(sns_topic_mock)

      subject.instance_variable_set(:@sns, sns_client_mock)
      # 

      call_publish

      expected_payload = { message: "{\"default\":{\"foo\":\"bar\"}}",
                           message_attributes: { "context" => { data_type: "String",
                                                                string_value: context },
                                                 "correlationId" => { data_type: "String",
                                                                      string_value: cid},
                                                 "eventId" =>
                                   { data_type: "String",
                                     string_value: event_id } },
                           message_structure: " json " }

      expect(sns_topic_mock).to have_received(:publish).with(expected_payload)
    end
  end
end
