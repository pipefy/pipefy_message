# frozen_string_literal: true

RSpec.shared_context "AWS stub" do
  before(:suite) do
    stub_const("ENV", ENV.to_hash.merge("AWS_CLI_STUB_RESPONSE" => "true"))
  end
end
