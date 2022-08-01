# frozen_string_literal: true

require "pipefy_message"

##
# Example consumer class.
class IdTestConsumer
  include PipefyMessage::Consumer
  options queue_name: "id-test-queue"

  def perform(message, metadata)
    puts "Received message #{message} from broker - retry #{metadata[:retry_count]}"
  end
end
