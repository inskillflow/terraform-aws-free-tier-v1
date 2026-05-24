"""UI Streamlit du TP 5 (multi-environnements dev / test).

L'environnement cible est lu dans la variable TF_ENVIRONMENT (defaut: dev).
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import streamlit as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lib.aws_clients import (  # noqa: E402
    ddb_resource,
    delete_message,
    get_caller_identity,
    list_buckets_with_prefix,
    list_table_items,
    queue_attributes,
    receive_messages,
    s3_client,
    send_message,
)

PROJECT_PREFIX = os.environ.get("PROJECT_PREFIX", "tfaws-student")
ENV = os.environ.get("TF_ENVIRONMENT", "dev")

st.set_page_config(page_title=f"TP 5 - Terraform AWS ({ENV})", layout="wide")
st.title(f"TP 5 - Terraform AWS Free Tier - environnement `{ENV}`")
st.caption("Changez l'environnement en redemarrant Streamlit avec TF_ENVIRONMENT=test.")

# -----------------------------------------------------------------------------
# Identite
# -----------------------------------------------------------------------------
with st.expander("Identite AWS", expanded=False):
    try:
        ident = get_caller_identity()
        st.json({k: ident.get(k) for k in ("UserId", "Account", "Arn")})
    except Exception as exc:  # noqa: BLE001
        st.error(f"STS error: {exc}")
        st.stop()

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------
st.header("S3")
buckets = list_buckets_with_prefix(PROJECT_PREFIX)
data_bucket = next((b for b in buckets if f"-tp5-{ENV}-data-" in b), None)
if data_bucket:
    st.success(f"Bucket TP 5 / {ENV} : `{data_bucket}`")
    uploaded = st.file_uploader("Uploader un fichier")
    if uploaded is not None:
        s3_client().put_object(Bucket=data_bucket, Key=uploaded.name, Body=uploaded.getvalue())
        st.success(f"`{uploaded.name}` uploade.")
    objs = s3_client().list_objects_v2(Bucket=data_bucket).get("Contents", [])
    if objs:
        st.table([{"Key": o["Key"], "Size": o["Size"]} for o in objs])
else:
    st.warning(f"Aucun bucket TP 5 / {ENV} detecte.")

# -----------------------------------------------------------------------------
# DynamoDB
# -----------------------------------------------------------------------------
st.header("DynamoDB")
items_table = f"{PROJECT_PREFIX}-tp5-{ENV}-items"
with st.form("add_item"):
    pk = st.text_input("pk", value="item-1")
    payload = st.text_area("Payload JSON", value='{"value": 1}')
    if st.form_submit_button("Ajouter / mettre a jour"):
        try:
            item = {"pk": pk, **json.loads(payload)}
            ddb_resource().Table(items_table).put_item(Item=item)
            st.success(f"Item `{pk}` ajoute.")
        except Exception as exc:  # noqa: BLE001
            st.error(f"Erreur DynamoDB: {exc}")

try:
    st.table(list_table_items(items_table))
except Exception as exc:  # noqa: BLE001
    st.error(f"Lecture table impossible: {exc}")

# -----------------------------------------------------------------------------
# SQS
# -----------------------------------------------------------------------------
st.header("SQS")
events_queue = f"{PROJECT_PREFIX}-tp5-{ENV}-events"

try:
    attrs = queue_attributes(events_queue)
    cols = st.columns(3)
    cols[0].metric("Messages disponibles", attrs.get("ApproximateNumberOfMessages", "?"))
    cols[1].metric("Messages 'in flight'", attrs.get("ApproximateNumberOfMessagesNotVisible", "?"))
    cols[2].metric("Messages retardes", attrs.get("ApproximateNumberOfMessagesDelayed", "?"))
except Exception as exc:  # noqa: BLE001
    st.error(f"Queue introuvable: {exc}")
    st.stop()

with st.form("send_msg"):
    body = st.text_area("Corps du message", value='{"event": "hello", "value": 1}')
    if st.form_submit_button("Envoyer dans SQS"):
        try:
            mid = send_message(events_queue, body)
            st.success(f"Envoye, MessageId = {mid}")
        except Exception as exc:  # noqa: BLE001
            st.error(f"Erreur send: {exc}")

if st.button("Recevoir jusqu'a 10 messages"):
    try:
        msgs = receive_messages(events_queue, max_messages=10)
        if not msgs:
            st.info("Aucun message visible (poll vide).")
        for m in msgs:
            st.code(m.get("Body", ""))
            if st.button(f"Supprimer {m['MessageId']}", key=m["MessageId"]):
                delete_message(events_queue, m["ReceiptHandle"])
                st.success("Supprime.")
    except Exception as exc:  # noqa: BLE001
        st.error(f"Erreur receive: {exc}")
