# frozen_string_literal: true

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
    @logger ||= Logger.new(logfile)
  end

  # Logger method available to all instances of classes
  # that include the Logging module (as an instance method).
  def logger
    Logging.logger
  end

  # See module ClassLogger and method ClassLogger::logger. This method
  # is required to include the logger method in ClassLogger as a class
  # (rather than an instance) method.
  def self.included(base)
    base.extend(ClassLogger)
  end

  # Encapsulates methods and attributes to be made available to classes rather than objects.
  module ClassLogger
    # Logger method available to all *classes* that include
    # the Logging module (as a static/class method).
    def logger
      Logging.logger
    end
  end
end
