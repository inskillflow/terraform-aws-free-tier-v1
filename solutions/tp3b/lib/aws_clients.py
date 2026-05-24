"""Helpers boto3 - TP 3 (ajoute SQS)."""

from __future__ import annotations

import os
from functools import lru_cache

import boto3


def _region() -> str:
    return os.environ.get("AWS_REGION") or os.environ.get("AWS_DEFAULT_REGION") or "us-east-1"


@lru_cache(maxsize=1)
def s3_client():
    return boto3.client("s3", region_name=_region())


@lru_cache(maxsize=1)
def ddb_resource():
    return boto3.resource("dynamodb", region_name=_region())


@lru_cache(maxsize=1)
def sqs_client():
    return boto3.client("sqs", region_name=_region())


@lru_cache(maxsize=1)
def sts_client():
    return boto3.client("sts", region_name=_region())


def get_caller_identity() -> dict:
    return sts_client().get_caller_identity()


def list_buckets_with_prefix(prefix: str) -> list[str]:
    buckets = s3_client().list_buckets().get("Buckets", [])
    return [b["Name"] for b in buckets if b["Name"].startswith(prefix)]


def list_table_items(table_name: str, limit: int = 50) -> list[dict]:
    table = ddb_resource().Table(table_name)
    return table.scan(Limit=limit).get("Items", [])


def queue_url(queue_name: str) -> str:
    return sqs_client().get_queue_url(QueueName=queue_name)["QueueUrl"]


def send_message(queue_name: str, body: str) -> str:
    url = queue_url(queue_name)
    resp = sqs_client().send_message(QueueUrl=url, MessageBody=body)
    return resp["MessageId"]


def receive_messages(queue_name: str, max_messages: int = 10) -> list[dict]:
    url = queue_url(queue_name)
    resp = sqs_client().receive_message(
        QueueUrl=url,
        MaxNumberOfMessages=max_messages,
        WaitTimeSeconds=2,  # short wait pour l'UI
    )
    return resp.get("Messages", [])


def delete_message(queue_name: str, receipt_handle: str) -> None:
    url = queue_url(queue_name)
    sqs_client().delete_message(QueueUrl=url, ReceiptHandle=receipt_handle)


def queue_attributes(queue_name: str) -> dict:
    url = queue_url(queue_name)
    return sqs_client().get_queue_attributes(
        QueueUrl=url,
        AttributeNames=["All"],
    ).get("Attributes", {})
