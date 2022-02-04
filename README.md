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

    $ bundle install

Or install it yourself as:

    $ gem install pipefy_message

## Usage

### Development

To test changes without install this dependency on your application, on the project root execute:

    $ bundle install
    $ gem build pipefy_message.gemspec
    $ gem install pipefy_message-0.1.0.gem

After that, we are going to test the gem with these commands:

    $ irb

On the irb console:

    $ require 'pipefy_message'
    $ message = PipefyMessage::Test.new
    $ message.hello

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pipefy/pipefy_message.

> Follow the [template](https://github.com/pipefy/pipefy_message/blob/main/.github/pull_request_template.md) while opening a PR
