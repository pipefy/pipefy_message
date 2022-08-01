localaws sns create-topic --name="id-test-topic"

{
    "TopicArn": "arn:aws:sns:us-east-1:000000000000:id-test-topic"
}


localaws sqs create-queue --queue-name="id-test-queue"

{
    "QueueUrl": "http://localhost:4566/000000000000/id-test-queue"
}

localaws sns subscribe --topic-arn="arn:aws:sns:us-east-1:000000000000:id-test-topic" --protocol="sqs" --notification-endpoint="arn:aws:sqs:us-east-1:000000000000:id-test-queue"