# Solution — TP 3 (S3 + DynamoDB + SQS + UI Streamlit)

Solution exécutable correspondant à [`../../03b-Chapitre3-Pratique-ajouter-sqs.md`](../../03b-Chapitre3-Pratique-ajouter-sqs.md).

> **ARGENT :** Free Tier (SQS 1 M req/mois). `terraform destroy` à la fin.

## Contenu identique au TP 2 + SQS

| Ajouté | Rôle |
|---|---|
| `terraform/main.tf` | `aws_sqs_queue.events` Standard, long polling, SSE managée |
| `lib/aws_clients.py` | helpers `send_message`, `receive_messages`, `delete_message` |
| `streamlit_app/app.py` | section SQS (envoyer, recevoir, supprimer) |

## Démarrage

```bash
cp .env.example .env
docker compose build
docker compose up -d tools
docker compose run --rm tools terraform -chdir=terraform init
docker compose run --rm tools terraform -chdir=terraform apply -auto-approve
docker compose up -d streamlit
```

Ouvrir http://localhost:8501

## Tests SQS via CLI

```bash
docker compose run --rm tools bash -lc '
URL=$(terraform -chdir=terraform output -raw events_queue_url)
aws sqs send-message --queue-url $URL --message-body "{\"hello\": \"world\"}"
aws sqs receive-message --queue-url $URL --max-number-of-messages 10 --wait-time-seconds 2
'
```

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down
```
