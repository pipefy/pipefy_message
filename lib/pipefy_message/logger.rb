# frozen_string_literal: true

require "English"
require "json"
require "logger"

module PipefyMessage
  # Custom Logger class to centralize and deal with logs needs
  class CustomLogger
    def retrieve_logger
      logger = Logger.new($stdout)
      log_level = ENV.fetch("ASYNC_LOG_LEVEL", "DEBUG")
      logger.level = log_level

      logger.formatter = proc do |severity, datetime, progname, msg|
        { level: severity != "ERROR" ? log_level : severity, timestamp: datetime.to_s,
          app: progname, context: "async_processing", message: msg }.to_json + $INPUT_RECORD_SEPARATOR
      end

      logger
    end
  end
end
