# frozen_string_literal: true

RSpec.describe PipefyMessage::BrokerConfiguration::AwsProvider::ProviderConfig do
  context "when I try to connect with AWS provider" do
    it "should return a hash with correct values" do
      keys = PipefyMessage::BrokerConfiguration::AwsProvider::ProviderConfig.instance.setup_connection

      expected = { endpoint: ENV["AWS_ENDPOINT"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                   secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"], region: "us-east-1",
                   stub_responses: (ENV["AWS_CLI_STUB_RESPONSE"] || false) }

      expect(keys).to eq expected
    end

    it "should return a Singleton" do
      first_instance = PipefyMessage::BrokerConfiguration::AwsProvider::ProviderConfig.instance
      second_instance = PipefyMessage::BrokerConfiguration::AwsProvider::ProviderConfig.instance

      expect(first_instance).to eq(second_instance)
    end
  end
end
