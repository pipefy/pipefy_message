# frozen_string_literal: true

require_relative "../../../lib/pipefy_message/providers/aws_client/sns_broker"
require_relative "aws_stub_context"

RSpec.describe PipefyMessage::Providers::AwsClient::SnsBroker do
  describe "#initialize" do
    let(:prefix) { "test" }
    let(:env_prefix) { "env" }

    it "should set the default ARN prefix from a hash arg" do
      sns_broker = described_class.new({ default_arn_prefix: prefix })
      default_prefix = sns_broker.config[:default_arn_prefix]

      expect(default_prefix).to eq prefix
      expect(sns_broker.topic_arn_prefix).to eq default_prefix
    end

    it "should have a default default ARN prefix" do
      sns_broker = described_class.new

      default_prefix = sns_broker.config[:default_arn_prefix]

      expect(default_prefix).to_not eq nil
      expect(sns_broker.topic_arn_prefix).to eq default_prefix
    end

    it "should use a nondefault ARN prefix from an env var" do
      stub_const("ENV", ENV.to_hash.merge({ "AWS_SNS_ARN_PREFIX" => env_prefix }))

      sns_broker = described_class.new

      expect(sns_broker.topic_arn_prefix).to eq env_prefix
      expect(sns_broker.config[:default_arn_prefix]).to_not eq env_prefix
    end
  end

  describe "#publish" do
    include_context "AWS stub"

    it "should return a message ID and a sequence number" do
      publisher = described_class.new

      payload = { foo: "bar" }
      topic_name = "pipefy-local-topic"

      result = publisher.publish(payload, topic_name)

      # AWS default stub values:
      expect(result.message_id).to eq "messageId"
      expect(result.sequence_number).to eq "String"
    end
  end
end
