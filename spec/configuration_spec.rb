# frozen_string_literal: true

RSpec.describe PipefyMessage::AwsProviderConfig do
  context "when I try to connect with AWS provider" do
    it "should return a hash with correct values" do
      keys = PipefyMessage::AwsProviderConfig.instance.do_connection

      expected = { endpoint: ENV["AWS_ENDPOINT"], access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                   secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"], region: "us-east-1" }

      expect(keys).to eq expected
    end

    it "should return a Singleton" do
      first_instance = PipefyMessage::AwsProviderConfig.instance
      second_instance = PipefyMessage::AwsProviderConfig.instance

      expect(first_instance).to eq(second_instance)
    end
  end
end
