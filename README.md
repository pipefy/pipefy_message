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

### Publisher

To use the publisher capabilities is required to "import our gem" at the desired class and call the publish method, see the example below:

```ruby
require "pipefy_message"

##
# Example publisher class.
class PublisherExampleClass
  def awesomeLogic
    
    ## business logic
    
    payload = { foo: "bar" }
    publisher = PipefyMessage::Publisher.new
    result = publisher.publish(payload, "pipefy-local-topic")
    puts result ## will print some data like the messageID and so on
  end
end
```

### Consumer

To use the consumer capabilities is required to "import our gem" at your consumer class, include the abstraction, define the `perform` method and finally call the method `process_message` to start the consuming process, see the example below:

```ruby
require "pipefy_message"

##
# Example consumer class.
class ConsumerExampleClass
  include PipefyMessage::Consumer
  options queue_name: "pipefy-local-queue"

  def perform(message)
    puts "Received message #{message} from broker"
    ## Fill with your business logic here
  end
end

ConsumerExampleClass.process_message
```

### Development - Test

To test changes without install this dependency on your application, on your terminal go to the project root and execute:
    
```console
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
    require_relative 'lib/samples/my_awesome_publisher.rb'
    publisher = MyAwesomePublisher.new
    publisher.publish
    ```

* Consume a message
    ```ruby
    require_relative 'lib/samples/my_awesome_consumer.rb'
    MyAwesomeConsumer.process_message
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

