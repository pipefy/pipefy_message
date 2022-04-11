# frozen_string_literal: true

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
    end
  end
end
