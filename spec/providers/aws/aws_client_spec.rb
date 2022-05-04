# frozen_string_literal: true

require "aws-sdk-sqs"

require_relative "../../../lib/pipefy_message/providers/aws_client/aws_client"

class TestClient
  include PipefyMessage::Providers::AwsClient

  def initialize
    PipefyMessage::Providers::AwsClient.aws_setup
  end
end

RSpec.describe PipefyMessage::Providers::AwsClient do
  describe "#initialize" do
    let(:aws_opts) do
      {
        access_key_id: "changing-some-default-values", # changed
        secret_access_key: "so-we-know-it-worked", # changed
        endpoint: "http://localhost:4566", # default (not set)
        region: "us-east-1", # default (not set)
        stub_responses: "true" # default (not set)
      }
    end

    before do
      changed_opts = {
        "AWS_ACCESS_KEY_ID" => aws_opts[:access_key_id],
        "AWS_SECRET_ACCESS_KEY" => aws_opts[:secret_access_key],
        "AWS_CLI_STUB_RESPONSE" => aws_opts[:stub_responses]
      }

      stub_const("ENV", ENV.to_hash.merge(changed_opts))
    end

    after do
      Aws.config = {} # undoing changes
      # (to avoid test "cross-contamination")
    end

    it "should read and set configurations from env vars" do
      TestClient.new
      expect(Aws.config).to eq aws_opts
    end

    it "should not set configurations more than once" do
      TestClient.new

      ENV["AWS_CLI_STUB_RESPONSE"] = "false"
      TestClient.new

      expect(Aws.config).to eq aws_opts
    end
  end
end
