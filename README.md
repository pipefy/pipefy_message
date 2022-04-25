# PipefyMessage

This project it's a gem who provides a simple way to produce and consume messages for async processing.

## Requirements

This project requires the following to run:

- Ruby 2.6.6
- [Bundler](https://bundler.io/)

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'pipefy_message'
```

And then execute:

```console
  bundle install
```

Or install it yourself as:

```console
  gem install pipefy_message
```

## Usage

### Development

To test changes without install this dependency on your application, on your terminal go to the project root and execute:
    
```console
  export AWS_ACCESS_KEY_ID=foo
  export AWS_SECRET_ACCESS_KEY=bar
  export AWS_ENDPOINT="http://localhost:4566"
  export ENABLE_AWS_CLIENT_CONFIG=true
  
  make build-app
  make build-app-infra
```

If you need to recreate the infra (SNS and SQS) run:

```console
  make recreate-app-infra
```

After that, we are going to test the gem with these commands:

```console
  irb
```

On the irb console:

* Publish a message
    ```ruby
    require 'pipefy_message'
    message = PipefyMessage::Test.new
    message.publish
    ```

* Consume a message
    ```ruby
      require "pipefy_message"

      class TestWorker
        include PipefyMessage::Worker
        pipefymessage_options broker: "sqs", queue_name: "pipefy-local-queue"

        def perform(message)
          puts message
        end
      end

      TestWorker.perform_async
    ```

    

* Publish and Consume a message
    ```ruby
    require 'pipefy_message'
    message = PipefyMessage::Test.new
    message.publish_and_consume
    ```

## Project Stack

- [Aws SDK Ruby - SNS & SQS](https://github.com/aws_client/aws-sdk-ruby)
- [Bundler](https://bundler.io/)
- Docker-compose
- [GitHub Actions](https://docs.github.com/en/actions)
- Makefile
- Ruby 2.6.6
- [Rubocop](https://github.com/rubocop/rubocop)

## Brokers Documentation

* [SNS & SQS User guide](https://github.com/pipefy/pipefy_message/tree/main/lib/pipefy_message/broker/aws_client/README.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pipefy/pipefy_message.

> Follow the [template](https://github.com/pipefy/pipefy_message/blob/main/.github/pull_request_template.md) while opening a PR

