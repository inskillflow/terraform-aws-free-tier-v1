"""Petits helpers boto3 pour le TP 2.

Aucun endpoint custom : on parle au vrai AWS via les credentials lues
depuis les variables d'environnement (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
AWS_DEFAULT_REGION) injectees par docker-compose.
"""

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
def sts_client():
    return boto3.client("sts", region_name=_region())


def get_caller_identity() -> dict:
    return sts_client().get_caller_identity()


def list_buckets_with_prefix(prefix: str) -> list[str]:
    buckets = s3_client().list_buckets().get("Buckets", [])
    return [b["Name"] for b in buckets if b["Name"].startswith(prefix)]


def list_table_items(table_name: str, limit: int = 50) -> list[dict]:
    table = ddb_resource().Table(table_name)
    resp = table.scan(Limit=limit)
    return resp.get("Items", [])
