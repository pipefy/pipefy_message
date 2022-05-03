# frozen_string_literal: true

require "aws-sdk-sqs"

require_relative "../../../lib/pipefy_message/providers/aws_client/sqs_broker"
require_relative "aws_stub_context"

RSpec.describe PipefyMessage::Providers::AwsClient::SqsBroker do
  include_context "AWS stub"

  describe "#initialize" do
    let(:test_queue) { "test-queue" }
    let(:sqs_opts) do
      {
        wait_time_seconds: 10, # default (not set)
        queue_name: test_queue # changed
      }
    end

    it "should set configurations vars from a hash arg or use defaults" do
      sqs_broker = described_class.new(queue_name: sqs_opts[:queue_name])

      expect(sqs_broker.config).to eq sqs_opts
    end
  end

  describe "#poller" do
    it "should consume a message" do
      mocked_message = { message_id: "44c44782-fee1-6784-d614-43b73c0bda8d",
                         receipt_handle: "2312dasdas1231221312321adsads",
                         body: "{\"Message\": {\"foo\": \"bar\"}}" }

      mocked_poller = Aws::SQS::QueuePoller.new("http://localhost:4566/000000000000/my_queue",
                                                { skip_delete: true })
      mocked_poller.before_request { |stats| throw :stop_polling if stats.received_message_count > 0 }

      mocked_element = Aws::SQS::Types::Message.new(mocked_message)
      mocked_list = Aws::Xml::DefaultList.new
      mocked_list.append(mocked_element)
      mocked_poller.client.stub_responses(:receive_message, messages: mocked_list)

      worker = described_class.new
      worker.instance_variable_set(:@poller, mocked_poller)

      result = nil
      expected_result = { "Message" => { "foo" => "bar" } }
      worker.poller do |message|
        result = message
      end
      expect(result).to eq expected_result
    end
  end

  describe "raised errors" do
    it "should raise NonExistentQueue" do
      allow_any_instance_of(Aws::SQS::Client)
        .to receive(:get_queue_url)
        .with({ queue_name: "pipefy-local-queue" })
        .and_raise(
          Aws::SQS::Errors::NonExistentQueue.new(
            double(Aws::SQS::Client),
            "The specified queue my_queue does not exist for this wsdl version"
          )
        )

      expect do
        described_class.new
      end.to raise_error(PipefyMessage::Providers::Errors::ResourceError,
                         /The specified queue my_queue does not exist for this wsdl version/)
    end
    it "should raise NetworkingError" do
      allow_any_instance_of(Aws::SQS::Client)
        .to receive(:get_queue_url)
        .with({ queue_name: "pipefy-local-queue" })
        .and_raise(
          Seahorse::Client::NetworkingError.new(
            Errno::ECONNREFUSED.new(""),
            "Failed to open TCP connection"
          )
        )

      expect do
        described_class.new("my_queue")
      end.to raise_error(PipefyMessage::Providers::Errors::ResourceError)
    end
  end
end
