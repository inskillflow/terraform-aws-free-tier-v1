"""UI Streamlit du TP 2.

Permet de :
  - voir l'identite AWS (sts get-caller-identity)
  - lister les buckets S3 prefixes par `PROJECT_PREFIX`
  - uploader un fichier dans le bucket "tp2-data"
  - lister et ajouter des items dans la table DynamoDB "tp2-items"
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import streamlit as st

# Permet d'importer lib/ depuis streamlit_app/
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from lib.aws_clients import (  # noqa: E402
    ddb_resource,
    get_caller_identity,
    list_buckets_with_prefix,
    list_table_items,
    s3_client,
)

PROJECT_PREFIX = os.environ.get("PROJECT_PREFIX", "tfaws-student")

st.set_page_config(page_title="TP 2 — Terraform AWS Free Tier", layout="wide")
st.title("TP 2 — Terraform AWS Free Tier (S3 + DynamoDB)")

# -----------------------------------------------------------------------------
# Identite AWS
# -----------------------------------------------------------------------------
with st.expander("Identite AWS (sts get-caller-identity)", expanded=True):
    try:
        ident = get_caller_identity()
        st.json({k: ident.get(k) for k in ("UserId", "Account", "Arn")})
    except Exception as exc:  # noqa: BLE001
        st.error(f"Impossible d'appeler STS : {exc}")
        st.stop()

# -----------------------------------------------------------------------------
# S3
# -----------------------------------------------------------------------------
st.header("S3")
buckets = list_buckets_with_prefix(PROJECT_PREFIX)
st.write(f"Buckets prefixes par `{PROJECT_PREFIX}` :")
st.write(buckets or "(aucun)")

data_bucket = next((b for b in buckets if "-tp2-data-" in b), None)
if data_bucket:
    st.success(f"Bucket de donnees TP 2 detecte : `{data_bucket}`")

    uploaded = st.file_uploader("Uploader un fichier dans le bucket")
    if uploaded is not None:
        key = uploaded.name
        s3_client().put_object(Bucket=data_bucket, Key=key, Body=uploaded.getvalue())
        st.success(f"Fichier `{key}` uploade dans `{data_bucket}`.")

    objs = s3_client().list_objects_v2(Bucket=data_bucket).get("Contents", [])
    if objs:
        st.write("Objets du bucket :")
        st.table([{"Key": o["Key"], "Size": o["Size"]} for o in objs])
else:
    st.warning("Aucun bucket TP 2 detecte. Avez-vous lance `terraform apply` ?")

# -----------------------------------------------------------------------------
# DynamoDB
# -----------------------------------------------------------------------------
st.header("DynamoDB")
items_table_name = f"{PROJECT_PREFIX}-tp2-items"
st.write(f"Table attendue : `{items_table_name}`")

with st.form("add_item"):
    pk = st.text_input("Cle primaire (pk)", value="item-1")
    payload = st.text_area("Payload JSON", value='{"value": 42, "note": "hello"}')
    submitted = st.form_submit_button("Ajouter / mettre a jour")
    if submitted:
        try:
            item = {"pk": pk, **json.loads(payload)}
            ddb_resource().Table(items_table_name).put_item(Item=item)
            st.success(f"Item `{pk}` ajoute.")
        except Exception as exc:  # noqa: BLE001
            st.error(f"Erreur : {exc}")

st.subheader("Items de la table")
try:
    items = list_table_items(items_table_name)
    if items:
        st.table(items)
    else:
        st.info("Table vide.")
except Exception as exc:  # noqa: BLE001
    st.error(f"Impossible de lire la table : {exc}")
