# frozen_string_literal: true

require_relative "providers/broker_resolver"

module PipefyMessage
  # Base Publisher provided by this gem, to be used for the external publishers to send messages to a broker
  class Publisher
    include PipefyMessage::Logging
    include PipefyMessage::Providers::BrokerResolver

    def initialize(broker = "aws", broker_opts = {})
      @broker = broker
      @broker_opts = broker_opts
      begin
        @publisher_instance = build_publisher_instance
      rescue StandardError => e
        logger.error({
                       broker: broker,
                       broker_opts: broker_opts,
                       log_text: "Failed to initialize #{broker} broker with #{e.inspect}"
                     })

        raise e
      end
    end

    def publish(message, topic, context = nil, correlation_id = nil)
      context = "NO_CONTEXT_PROVIDED" if context.nil?
      correlation_id = "NO_CID_PROVIDED" if correlation_id.nil?
      event_id = SecureRandom.uuid.to_s

      @publisher_instance.publish(message, topic, context, correlation_id, event_id)
    rescue StandardError => e
      logger.error(log_context({
                                 topic_name: topic,
                                 message: message,
                                 log_text: "Failed to publish message to topic #{topic} with #{e.inspect}"
                               }, context, correlation_id, event_id))

      raise e
    end

    private

    ##
    # Initializes and returns an instance of a broker for
    # the provider specified in the class options.
    def build_publisher_instance
      publisher_map = resolve_broker(@broker, "publisher")
      publisher_map[:class_name].constantize.new(@broker_opts)
    end
  end
end
