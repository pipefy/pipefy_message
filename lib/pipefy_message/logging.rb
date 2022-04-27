# frozen_string_literal: true

require "logger"
require "json"

module PipefyMessage
  ##
  # Provides a shared logger setup to all classes and instances of
  # classes that require logging, when included.
  #
  # For instance: if class Test includes Logging, and test is an
  # instance of Test (eg: test = Test.new), then both Test.logger and
  # test.logger should provide a working logger with the same
  # configurations.
  #
  # (see https://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes)
  module Logging
    ##
    # Creates a logger object if it has not yet been instantiated,
    # or returns the existing object.
    def self.logger
      @logger ||= logger_setup
    end

    ##
    # Configuration for a logger created by the Ruby logger gem.
    def self.logger_setup
      loglevels = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze
      logger = Logger.new($stdout)
      level ||= loglevels.index ENV.fetch("ASYNC_LOG_LEVEL", "INFO")
      level ||= Logger::ERROR
      logger.level = level
      logger
    end

    ##
    # Formats logger output as a JSON object, including information on
    # the calling object. Should not be called directly; this method is
    # called implicitly whenever a logger method is called.
    def self.json_output(obj, severity, datetime, progname, msg)
      { date: datetime.to_s,
        level: severity.to_s,
        app: progname.to_s,
        context: "async_processing",
        message: msg }
    end

    ##
    # Logger method available to all instances of classes
    # that include the Logging module (as an instance method).
    # Includes information on the calling object.
    def logger
      Logging.logger.formatter = proc do |severity, datetime, progname, msg|
        json_hash = Logging.json_output(self, severity, datetime, progname, msg)

        # The necessity of explicitly JSON.dumping this hash has been
        # discussed in a code review. We should check how these logs
        # will be processed on the other end and perhaps refactor
        # accordingly.
        JSON.dump(json_hash) + ($INPUT_RECORD_SEPARATOR || "\n")
      end

      Logging.logger
    end

    ##
    # Includes module attributes and methods as class/static (rather
    # than just instance) attributes and methods.
    def self.included(base)
      base.extend(self)
    end
  end
end
