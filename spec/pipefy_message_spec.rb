# frozen_string_literal: true

RSpec.describe PipefyMessage do
  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end
end
