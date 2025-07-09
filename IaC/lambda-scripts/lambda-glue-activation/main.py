import boto3
import logging
import os 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

client = boto3.client("glue")

job_name = os.environ["JOB_NAME"]

def handler(event, context):
    logger.info(f"## INITIATED BY EVENT: {event['detail']}")

    response = client.start_job_run(JobName=job_name)
    logger.info(f"## STARTED GLUE JOB: {job_name}")
    logger.info(f"## GLUE JOB RUN ID: {response['JobRunId']}")
    return response