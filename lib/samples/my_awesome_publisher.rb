# frozen_string_literal: true

require "pipefy_message"

##
# Example publisher class.
class MyAwesomePublisher
  def publish
    payload = { foo: "bar" }
    publisher = PipefyMessage::Publisher.new
    result = publisher.publish(payload, "pipefy-local-topic")
    puts result
  end
end
