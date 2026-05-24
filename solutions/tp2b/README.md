# Solution — TP 2 (S3 + DynamoDB + UI Streamlit)

Solution exécutable correspondant à [`../../02b-Chapitre2-Pratique-ajout-ui-streamlit.md`](../../02b-Chapitre2-Pratique-ajout-ui-streamlit.md).

> **ARGENT :** Free Tier. `terraform destroy` à la fin.

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | services `tools` + `streamlit` |
| `Dockerfile.tools` | Terraform + AWS CLI + boto3 |
| `Dockerfile.streamlit` | Streamlit + boto3 |
| `terraform/` | S3 + DynamoDB |
| `lib/aws_clients.py` | Helpers boto3 réutilisables |
| `streamlit_app/app.py` | UI |

## Démarrage

```bash
cp .env.example .env
# Editer .env (clés AWS, prefix)

docker compose build
docker compose up -d tools

docker compose run --rm tools terraform -chdir=terraform init
docker compose run --rm tools terraform -chdir=terraform apply -auto-approve

docker compose up -d streamlit
```

Ouvrir http://localhost:8501

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down
```
