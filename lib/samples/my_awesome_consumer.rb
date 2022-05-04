# frozen_string_literal: true

require "pipefy_message"

##
# Example consumer class.
class MyAwesomeConsumer
  include PipefyMessage::Consumer
  options queue_name: "pipefy-local-queue"

  def perform(message)
    puts "Received message #{message} from broker"
    ## Fill with our logic here
  end
end
