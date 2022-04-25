# frozen_string_literal: true

module PipefyMessage
  # Base Publisher provided by this gem, to be used for the external publishers to send messages to a broker
  class Publisher
    include PipefyMessage::Logging

    def initialize(broker = "aws")
      @broker = broker
    end

    def publish(message, topic)
      publisher_instance.publish(message, topic)
    end

    private

    def publisher_instance
      map = PipefyMessage.class_path[@broker.to_sym]
      require_relative map[:publisher][:relative_path]

      logger.info({
                    broker: @broker,
                    message_text: "Initializing and returning instance of #{@broker} broker"
                  })

      map[:publisher][:class_name].constantize.new
    end
  end
end
