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
    let(:expected_result) { { "default" => { "foo" => "bar" } }.to_json }

    context "Raw Message Delivery disabled" do
      let(:mocked_message) do
        {
          message_id: "44c44782-fee1-6784-d614-43b73c0bda8d",
          receipt_handle: "2312dasdas1231221312321adsads",
          body: "{\n  \"Type\" : \"Notification\",\n  \"MessageId\" : \"6c7057f5-0d43-54ad-a502-0c9a4b6cdcf1\",\n  \"TopicArn\" : \"arn:aws:sns:us-east-1:038527119583:core-card-field-value-updated-topic\",\n  \"Message\" : \"{\\\"default\\\":{\\\"foo\\\":\\\"bar\\\"}}\",\n  \"Timestamp\" : \"2022-08-11T18:01:19.875Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"GrOeiHuqVV9eB+RAWZ2XYe2ko/KXxnxVhQ/sW8zV3ybgO0UD6BI32XL/mw4r562msXpG0BZc7dFbJG6XPVcQ7YZWnVKU7c34nS9NyTimMTz5Df/raKCdVkxigMhbS45CPMC//u7Sz9fDb/MXTrInnuSVPY14/QwEwXqyV45M+lTzLoBJSM05UX0eo1MOQxRQ8IYgPay5z6BSSHq4B6/59U88PMv4VJLNaWIb8dTiO1ixK9Nz7Xk/dqqC/bI6A+VLUNhVSitDfkDaPPoSG5qFnBPRzpcQhznANkjecW6MSWtCf0R8BuSqAYNxoCzDcC5xOf3zJOccfUTwvxz5f5jwfg==\",\n  \"SigningCertURL\" : \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-56e67fcb41f6fec09b0196692625d385.pem\",\n  \"UnsubscribeURL\" : \"https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:038527119583:core-card-field-value-updated-topic:995474b4-3a57-4c94-abdf-3ba50244723d\",\n  \"MessageAttributes\" : {\n    \"eventId\" : {\"Type\":\"String\",\"Value\":\"30043493-d47d-4445-b5f6-17881df4b5f3\"},\n    \"context\" : {\"Type\":\"String\",\"Value\":\"NO_CONTEXT_PROVIDED\"},\n    \"correlationId\" : {\"Type\":\"String\",\"Value\":\"b41daa3fa2f0469eed7fc5b0534f0bc6\"}\n  }\n}"
        }
      end

      it "should consume a message " do
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
        worker.poller do |message|
          result = message
        end
        expect(result).to eq expected_result
      end
    end

    context "Raw Message Delivery enabled" do
      let(:mocked_message) do
        {
          message_id: "44c44782-fee1-6784-d614-43b73c0bda8d",
          receipt_handle: "2312dasdas1231221312321adsads",
          body: "{\"default\":{\"foo\":\"bar\"}}"
        }
      end

      it "should consume a message " do
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
        worker.poller do |message|
          result = message
        end
        expect(result).to eq expected_result
      end
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
