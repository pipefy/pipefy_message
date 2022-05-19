# typed: true
# frozen_string_literal: true

require "pipefy_message"
class PipefyMessagesWorker
  include PipefyMessage::Consumer
  options queue_name: "pipefy-local-queue"

  def perform(message)
    ## service qualquer
    puts "Received message #{message} from broker"
  end
end

PipefyMessagesWorker.process_message
