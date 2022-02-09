# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/configuration"
require "pry"

module PipefyMessage
  # Simple Test class to validate the project
  class Test
    def hello
      connection = PipefyMessage::AwsProviderConfig.instance

      sns = Aws::SNS::Resource.new

      puts connection.do_connection
      puts sns.topics
      puts "It's Alive !"
    end
  end
end
