# frozen_string_literal: true

require_relative "lib/pipefy_message/version"

Gem::Specification.new do |spec|
  spec.name          = "pipefy_message"
  spec.version       = PipefyMessage::VERSION
  spec.authors       = ["Platform team"]
  spec.email         = ["platform@pipefy.com"]

  spec.summary       = "Pipefy Message Pub/Sub Gem"
  spec.description   = "A gem who provides a simple way to publish and consume messages"
  spec.homepage      = "https://github.com/pipefy/pipefy_message"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pipefy/pipefy_message"
  spec.metadata["changelog_uri"] = "https://github.com/pipefy/pipefy_message/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  # spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.executables   = %w[pipefymessage]
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency  "aws-sdk-sns", "~> 1.50.0"
  spec.add_dependency  "aws-sdk-sqs", "~> 1.49.0"
  spec.add_dependency "thor"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
