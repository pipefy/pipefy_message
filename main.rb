require "pipefy_message"

class TestWorker
  include PipefyMessage::Worker
  pipefymessage_options broker: "aws", queue_name: "pipefy-local-queue"

  def perform(message)
    puts message
  end
end

TestWorker.process_message
