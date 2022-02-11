# AWS SNS & SQS User Guide

## Basics

**SNS**: Amazon Simple Notification Service (SNS) is a fully managed pub/sub messaging, SMS, email, and mobile push notifications. More details at the [official website](https://aws.amazon.com/sns/).

**SQS**: Amazon Simple Queue Service (SQS) is a fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications. More details at the [official website](https://aws.amazon.com/sqs/).

### Aws-cli Installation

Before proceed to the next step it's required to have the aws-cli installed in your machine, for that follow [this guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

> **Note that we must have the project docker-compose localstack service running before executing the commands above**
### Creating new SNS Topic

On your terminal run:

```bash
aws --endpoint-url=http://localhost:4566 sns create-topic --name pipe-events-topic
```
The expected output is:
```bash
{
  "TopicArn": "arn:aws:sns:us-east-1:000000000000:pipe-events-topic"
}
```

Parameters:
* **name** is the final topic name that will be used at localstack (can be changed for any name).

### Creating new SQS Queue

On your terminal run:

```bash
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name pipe-events-queue
```
The expected output is:
```bash
{
  "QueueUrl": "http://localhost:4566/000000000000/pipe-events-queue"
}
```

Parameters:
* **queue-name** is the final queue name that will be used at localstack (can be changed for any name).

### Creating a new Subscription from SQS to SNS topic

On your terminal run:

```bash
aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:us-east-1:000000000000:pipe-events-topic --protocol sqs --notification-endpoint http://localhost:4566/000000000000/pipe-events-queue
```
The expected output is:
```bash
{
  "QueueUrl": "http://localhost:4566/000000000000/pipe-events-queue"
}
```
Parameters:
* **topic-arn** is the output of the topic creation.
* **notification-endpoint** is the output of the queue creation.
