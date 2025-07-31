import boto3
import os

QUERUE_URL = os.environ["QUEUE_URL"]
sqs = boto3.client("sqs")

def handler(event, context):
    messages = []

    while True:
        response = sqs.receive_message(
            QueueUrl = QUERUE_URL,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=0
        )

        if "Message" not in response:
            break

        for msg in response["Messages"]:
            messages.append(msg["Body"])

            sqs.delete_message(
                QueueUrl=QUERUE_URL,
                ReceiptHandle=msg["ReceiptHandle"]
            )

    print(f"{len(messages)} messagens processeds")