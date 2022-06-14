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

      expect(sqs_broker.instance_variable_get(:@config)).to eq sqs_opts
    end

    it "should convert HTTP URLs to HTTPS by environment" do
      [{ env: "staging", expected_protocol: "https" },
       { env: "development", expected_protocol: "http" },
       { env: "prod", expected_protocol: "https" }].each do |obj|
        ENV["ASYNC_APP_ENV"] = obj[:env]
        mock_sqs_client = instance_double("Aws::SQS::Client")
        mocked_queue_url = Aws::SQS::Types::GetQueueUrlResult.new(queue_url: "http://fake/url")
        allow(mock_sqs_client).to receive(:get_queue_url).and_return(mocked_queue_url)
        allow(Aws::SQS::Client).to receive(:new).and_return(mock_sqs_client)

        sqs_broker = described_class.new(queue_name: sqs_opts[:queue_name])

        expected_queue_url = "#{obj[:expected_protocol]}://fake/url"
        expect(sqs_broker.instance_variable_get(:@poller).instance_variable_get(:@queue_url)).to eq expected_queue_url
      end
    end
  end

  it "should handle queue name by environment " do
    [{ env: "staging", expected_queue_name: "test_queue-staging" },
     { env: "dev", expected_queue_name: "test_queue" },
     { env: "prod", expected_queue_name: "test_queue" }].each do |obj|
      ENV["ASYNC_APP_ENV"] = obj[:env]
      mock_sqs_client = instance_double("Aws::SQS::Client")
      allow(mock_sqs_client).to receive(:get_queue_url).and_return(Aws::SQS::Types::GetQueueUrlResult.new(queue_url: "http://fake/url"))
      allow(Aws::SQS::Client).to receive(:new).and_return(mock_sqs_client)

      described_class.new(queue_name: "test_queue")

      expect(mock_sqs_client).to have_received(:get_queue_url).with({ queue_name: obj[:expected_queue_name] })
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
