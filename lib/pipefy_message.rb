# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/logging"
require_relative "pipefy_message/publisher"
require_relative "pipefy_message/consumer"
require_relative "pipefy_message/providers/errors"

require "logger"
require "json"
require "benchmark"
require "active_support"
require "active_support/core_ext/string/inflections"

##
# PipefyMessage abstraction async process
##
module PipefyMessage
end
