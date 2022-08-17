# frozen_string_literal: true

require "English"
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
    LOG_LEVELS = %w[DEBUG INFO WARN ERROR FATAL UNKNOWN].freeze

    ##
    # Creates a logger object if it has not yet been instantiated,
    # or returns the existing object.
    def logger
      @logger ||= Logging.logger_setup
    end

    ##
    # Configuration for a logger created by the Ruby logger gem.
    def self.logger_setup
      Logger.new($stdout).tap do |logger|
        logger.level = LOG_LEVELS.index(ENV.fetch("ASYNC_LOG_LEVEL", "INFO")) || Logger::ERROR

        logger.formatter = proc do |severity, datetime, progname, msg|
          msg_hash = msg.is_a?(Hash) ? msg : { log_text: msg }
          { time: datetime.to_s,
            level: severity.to_s,
            program_name: progname.to_s,
            context: "async_processing",
            data: msg_hash }.to_json + $INPUT_RECORD_SEPARATOR
        end
      end
    end

    ##
    # Includes module attributes and methods as class/static (rather
    # than just instance) attributes and methods.
    def self.included(base)
      base.extend(self)
    end

    ##
    # Adds context, correlation and event identifiers to logs. Should be
    # called with the hash containing the remainder of the logs as
    # argument, eg: logger.info(log_context({ ... }, context, correlation_id, event_id)).
    def log_context(log_hash, context, correlation_id, event_id)
      {
        context: context,
        correlation_id: correlation_id,
        event_id: event_id
      }.merge(log_hash)
    end
  end
end
