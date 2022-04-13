# frozen_string_literal: true

require 'singleton'

module PipefyMessage
  # ClassMethods
  module Worker
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # ClassMethods
    module ClassMethods 
      def pipefymessage_options(opts = {})        
        options_hash = PipefyMessage.default_worker_options.merge(opts.transform_keys(&:to_s))
        options_hash.each do |k, v|
          singleton_class.class_eval { attr_accessor k }
          send("#{k}=", v)
        end
      end
      
      def perform_async()  
        begin
          obj = self.new 
          build_instance_broker.poller do |message|
            obj.perform(message)
          end
        rescue Exception => exception
          # TODO: Implement retry
          raise exception
        end
      end

      def build_instance_broker()        
        map = {"aws" => "PipefyMessage::Providers::AwsBroker"}
        require_relative "providers/#{self.broker}_broker"
        
        map[self.broker].constantize.new(self.queue)
      end
    end
  end
end
