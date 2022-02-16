# frozen_string_literal: true

RSpec.describe PipefyMessage::BaseConsumer do
  context "when I try to consume a message from SQS broker" do
    before do
      ENV["AWS_ENDPOINT"] = "http://localhost:4566"
      ENV["AWS_ACCESS_KEY_ID"] = "foo"
      ENV["AWS_SECRET_ACCESS_KEY"] = "bar"
    end
    it "should consumer a message properly" do
      consumer = PipefyMessage::BaseConsumer.new("http://localhost:4566/000000000000/pipefy-local-queue-test")
      mocked_message = { message_id: "44c44782-fee1-6784-d614-43b73c0bda8d",
                         receipt_handle: "2312dasdas1231221312321adsads",
                         body: "{\"Message\": {\"foo\": \"bar\"}}" }

      mocked_poller = Aws::SQS::QueuePoller.new("http://localhost:4566/000000000000/pipefy-local-queue-test",
                                                { skip_delete: true })
      mocked_poller.before_request { |stats| throw :stop_polling if stats.received_message_count > 0 }

      mocked_element = Aws::SQS::Types::Message.new(mocked_message)
      mocked_list = Aws::Xml::DefaultList.new
      mocked_list.append(mocked_element)

      mocked_poller.client.stub_responses(:receive_message, messages: mocked_list)
      consumer.instance_variable_set(:@poller, mocked_poller)

      result = consumer.consume_message
      expect(result.received_message_count).to eq 1
    end
  end
end
