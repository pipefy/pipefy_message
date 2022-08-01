# frozen_string_literal: true

require "pipefy_message"

# ...
class IdTestPublisher < PipefyMessage::Publisher; end

# ...
class IdTestConsumer
  include PipefyMessage::Consumer
  options queue_name: "pipefy-local-queue"

  def perform(message, metadata)
    puts "Received message #{message} from broker - retry #{metadata[:retry_count]}"
  end
end

pub = IdTestPublisher.new
cons = IdTestConsumer.new

require "pry"; binding.pry