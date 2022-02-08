# frozen_string_literal: true

require_relative "pipefy_message/version"
require_relative "pipefy_message/configuration"

module PipefyMessage
  # Simple Test class to validate the project
  class Test

    def hello
      sns = Aws::SNS::Resource.new

      puts sns.topics
      puts "It's Alive !"
    end
  end
end
