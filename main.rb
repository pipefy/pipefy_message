# frozen_string_literal: true

require "pipefy_message"

##
# Example worker class.
class TestWorker
  include PipefyMessage::Worker
  pipefymessage_options broker: "aws", queue_name: "pipefy-local-queue"

  def perform(message)
    puts message
  end
end

TestWorker.process_message
