# frozen_string_literal: true

require_relative "providers/broker_resolver"

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

    ##
    # Initializes and returns an instance of a broker for
    # the provider specified in the class options.
    def publisher_instance
      provider_map = PipefyMessage::Providers::BrokerResolver.class_path[@broker.to_sym]

      if provider_map.nil?
        error_msg = "Invalid provider specified: #{@broker}"

        raise PipefyMessage::Providers::Errors::InvalidOption, error_msg
      end

      publisher_map = provider_map[:publisher]
      require_relative publisher_map[:relative_path]

      logger.info({
                    broker: @broker,
                    message_text: "Initializing and returning instance of #{@broker} broker"
                  })

      publisher_map[:class_name].constantize.new
    end
  end
end
