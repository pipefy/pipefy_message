# frozen_string_literal: true

require "English"
require "json"
require "logger"

module PipefyMessage
  # Custom Logger class to centralize and deal with logs needs
  class CustomLogger
    def initialize
      @logger = Logger.new($stdout)
      @is_log_enable = ENV.fetch("ASYNC_ENABLE_NON_ERROR_LOGS", "true") == "true"

      @logger.formatter = proc do |severity, datetime, progname, msg|
        { level: severity, timestamp: datetime.to_s, app: progname,
          context: "async_processing", message: msg }.to_json + $INPUT_RECORD_SEPARATOR
      end
    end

    def info(message)
      return unless @is_log_enable

      @logger.info(message)
    end

    def debug(message)
      return unless @is_log_enable

      @logger.debug(message)
    end

    def warn(message)
      return unless @is_log_enable

      @logger.warn(message)
    end

    def error(message)
      @logger.error(message)
    end
  end
end
