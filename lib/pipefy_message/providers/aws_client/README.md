# User guide: AWS SNS & SQS with localstack and aws-cli

## Basic concepts

**SNS**: Amazon Simple Notification Service (SNS) is a fully managed pub/sub messaging, SMS, email, and mobile push notifications. More details at the [official website](https://aws.amazon.com/sns/).

**SQS**: Amazon Simple Queue Service (SQS) is a fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications. More details at the [official website](https://aws.amazon.com/sqs/).

**localstack**: Localstack provides a local, containerized implementation of cloud services for testing and development. More details at the [official website](https://localstack.cloud/).

**aws-cli**: The official command-line interface for AWS. More details at the [official website](https://docs.aws.amazon.com/cli/index.html).

## Setup
This guide will aid you in setting up a local "instance" of the SQS and SNS services inside a Docker container using localstack. Real-world AWS credentials are not required.
### Aws-cli Installation
To follow the instructions in the next sections, you will still need to install the aws-cli in your machine. In order to do so, please refer to [the official installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

> **Note that we must have the project docker-compose localstack service running before executing the commands above**

### Creating localstack container
By running
```bash
docker-compose up localstack -d
```
you will start a container running localstack, whose ports 4566 and 4571 are mapped to the ports with the same numbers in the host machine. You will then be able to use `http://localhost:4566` to access the local AWS "clone" provided by localstack.

**Troubleshooting note:** this command might fail if those ports are currently in use. In that case, you could manually create a container based on the `localstack/localstack-light:0.11.5` image, mapping the ports above to any other that are available on your machine. If you do so, remember to change the ports referred to by the commands below accordingly.

## Using SQS and SNS with localstack
This section contains a brief outline on how to use basic commands that might be useful for testing a localstack setup. Please refer to the [official AWS CLI documentation](https://docs.aws.amazon.com/cli/index.html) for more information.

The alphanumeric strings on the expected outputs listed below might be different from the ones you see.
### Creating a new SNS topic

On your terminal, run:

```bash
aws --endpoint-url=http://localhost:4566 sns create-topic --name pipe-events-topic
```
**Parameters:** 
* `name` is the final topic name that will be used on localstack; the value `pipe-events-topic` can be changed for any other name.

The expected output is:
```bash
{
  "TopicArn": "arn:aws:sns:us-east-1:000000000000:pipe-events-topic"
}
```

### Creating a new SQS queue

On your terminal, run:

```bash
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name pipe-events-queue
```
**Parameters:** 
* `name` is the final queue name that will be used on localstack; the value `pipe-events-queue` can be changed for any other name.

The expected output is:
```bash
{
  "QueueUrl": "http://localhost:4566/000000000000/pipe-events-queue"
}
```

### Subscribing an SQS queue to an SNS topic

On your terminal, run:

```bash
aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:us-east-1:000000000000:pipe-events-topic --protocol sqs --notification-endpoint http://localhost:4566/000000000000/pipe-events-queue
```
**Parameters:** 
* `topic-arn` is the output of the topic creation step.
* `notification-endpoint` is the output of the queue creation step.

The expected output is:
```bash
{
  "SubscriptionArn": "arn:aws:sns:us-east-1:000000000000:pipe-events-topic:d5a44fe9-267b-4d10-b293-9b7f75f2ca09"
}
```

### Publishing to an SNS topic
On your terminal, run:

```bash
aws --endpoint-url=http://localhost:4566 sns publish --topic-arn arn:aws:sns:us-east-1:000000000000:pipe-events-topic --message "hello world"
```
**Parameters:** 
* `topic-arn` is the output of the topic creation step.
* `message` is a string containing the message payload.

The expected output is:
```bash
{
    "MessageId": "baa71695-138d-4fd5-af6b-0d4da01cfa96"
}
```

### Receiving a message from an SQS queue
On your terminal, run:

```bash
aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url http://localhost:4566/000000000000/pipe-events-queue
```
**Parameters:** 
* `queue-url` is the output of the topic creation step.

The expected output is:
```bash
{
    "Messages": [
        {
            "MessageId": "9c9ef40f-627b-bc26-845c-7ed76336fa87",
            "ReceiptHandle": "flhheyojgccjatkhvycjssradvtplujdnbmrubjmfolsdnxzrezbwjfjnstzzmkudsoiyejzlqblcxvyxyebngtvzrppjymuukrwwfzebxkpbptqhulwtiiyousjvqmjqvwgdojhyfeiugqudbgmqgpmogtpoajmncnnpmwlybvylzlmdqvdkqosu",
            "MD5OfBody": "aa79e44b37436d5d152323b3a3639440",
            "Body": "{\"Type\": \"Notification\", \"MessageId\": \"baa71695-138d-4fd5-af6b-0d4da01cfa96\", \"Token\": null, \"TopicArn\": \"arn:aws:sns:us-east-1:000000000000:pipefy-local-topic\", \"Message\": \"hello world\", \"SubscribeURL\": null, \"Timestamp\": \"2022-04-29T15:09:53.968Z\", \"SignatureVersion\": \"1\", \"Signature\": \"EXAMPLEpH+..\", \"SigningCertURL\": \"https://sns.us-east-1.amazonaws.com/SimpleNotificationService-0000000000000000000000.pem\"}",
            "Attributes": {
                "SenderId": "AIDAIT2UOQQY3AUEKVGXU",
                "SentTimestamp": "1651244993976",
                "ApproximateReceiveCount": "1",
                "ApproximateFirstReceiveTimestamp": "1651245077666"
            }
        }
    ]
}
```

Note that, since our queue is subscribed to our topic, the message we received above was the one sent in the previous step (`hello world`).