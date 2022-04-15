# frozen_string_literal: true

require_relative "../../lib/pipefy_message/providers/aws_broker"

RSpec.describe PipefyMessage::Providers::AwsBroker do
  context "#AwsBroker" do
    before do
      stub_const("ENV", ENV.to_hash.merge("AWS_CLI_STUB_RESPONSE" => "true"))
    end

    describe "#poller" do
      mocked_poller = nil

      before do
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
      end
      it "should consume message" do
        worker = PipefyMessage::Providers::AwsBroker.new("my_queue")
        worker.instance_variable_set(:@poller, mocked_poller)

        result = nil
        expected_result = { "Message" => { "foo" => "bar" } }
        worker.poller do |message|
          result = message
        end
        expect(result).to eq expected_result
      end
    end

    describe "should raise Errors" do
      it "QueueNonExistError" do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:get_queue_url)
          .with({ queue_name: "my_queue" })
          .and_raise(
            Aws::SQS::Errors::NonExistentQueue.new(
              double(Aws::SQS::Client),
              "The specified queue my_queue does not exist for this wsdl version"
            )
          )

        expect do
          PipefyMessage::Providers::AwsBroker.new("my_queue")
        end.to raise_error(PipefyMessage::Providers::Errors::ResourceError,
                           /The specified queue my_queue does not exist for this wsdl version/)
      end
      it "NetworkingError" do
        allow_any_instance_of(Aws::SQS::Client)
          .to receive(:get_queue_url)
          .with({ queue_name: "my_queue" })
          .and_raise(
            Seahorse::Client::NetworkingError.new(
              Errno::ECONNREFUSED.new(""),
              "Failed to open TCP connection"
            )
          )

        expect do
          PipefyMessage::Providers::AwsBroker.new("my_queue")
        end.to raise_error(PipefyMessage::Providers::Errors::ResourceError)
      end
    end
  end
end