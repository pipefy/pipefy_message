# frozen_string_literal: true

require "pipefy_message"

##
# Example consumer class.
class MyAwesomeConsumer
  include PipefyMessage::Consumer
  options queue_name: "pipefy-local-queue"

  def perform(message, metadata)
    puts "Received message #{message} from broker - retry #{metadata[:retry_count]}"
    ## Fill with our logic here
  end
end
