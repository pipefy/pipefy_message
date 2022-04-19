# frozen_string_literal: true

require "logger"
require "json"

module PipefyMessage
  # Provides a shared logger setup to all classes and instances of classes
  # that require logging, when included.
  #
  # For instance: if class Test includes Logging, and test is an instance
  # of Test (eg: test = Test.new), then both Test.logger and test.logger
  # should provide a working logger with the same configurations.
  #
  # (see https://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes)
  module Logging
    # Destination where logs should be saved.
    def self.logfile
      $stdout
    end

    # Creates a logger object if it has not yet been instantiated,
    # or returns the existing object.
    def self.logger
      @logger ||= logger_setup
    end

    # Configuration for a logger created by the Ruby logger gem.
    def self.logger_setup
      logger = Logger.new(logfile)

      # logger.formatter = proc do |severity, datetime, progname, msg|
      #   JSON.dump(date: "#{formatted_timestamp(datetime)}", severity:"#{severity}", message: msg) + "\n"
      # end

      logger
    end

    # Allows for custom datetime formatting. Return the datetime
    # parameter to use the default.
    def self.formatted_timestamp(datetime)
      # datetime.strftime("%Y-%m-%d %H:%M:%S")
      datetime
    end

    # Formats logger output as a JSON object, including information on
    # the calling object. Should not be called directly; this method is
    # called implicitly whenever a logger method is called. 
    def self.json_output(obj, severity, datetime, progname, msg)
      timestamp = formatted_timestamp(datetime)

      {:date => "#{timestamp}",
      :severity => "#{severity}",
      :calling_obj => "#{obj}",
      :calling_obj_class => "#{obj.class}",
      :message => msg}
    end

    # Logger method available to all instances of classes
    # that include the Logging module (as an instance method).
    # Includes information on the calling object.
    def logger
      Logging.logger.formatter = proc do |severity, datetime, progname, msg|
        json_hash = Logging.json_output(self, severity, datetime, progname, msg)

        JSON.dump(json_hash) + "\n"
      end
      
      Logging.logger
    end

    # Includes module attributes and methods as *class*/static (rather
    # than just instance) attributes and methods.
    def self.included(base)
      base.extend(self)
    end
  end
end
