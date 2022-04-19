# frozen_string_literal: true

class LoggerTester
  include PipefyMessage::Logging
end

# Tbh, I dunno how to make these "real" tests; this is essentially
# a huge makefile for automating manually checked tests atm :P But
# it's better than nothing nor now.
RSpec.describe LoggerTester do
  it "is available as an instance method" do
    subject.logger.error("Instance logger error")
  end

  it "is available as a class method" do
    described_class.logger.info("Class logger info")
  end
end
