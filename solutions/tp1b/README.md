# Solution — TP 1 (S3 + DynamoDB sur AWS réel)

Solution exécutable correspondant à [`../../01b-Chapitre1-Pratique-premier-projet-terraform-s3-dynamodb.md`](../../01b-Chapitre1-Pratique-premier-projet-terraform-s3-dynamodb.md).

> **ARGENT :** ressources Free Tier (S3 5 Go, DynamoDB On-Demand 25 unités gratuites). **N'oubliez pas `terraform destroy` à la fin de la session.**

---

## Contenu

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | Service `tools` |
| `Dockerfile.tools` | Image avec Terraform + AWS CLI + boto3 |
| `.env.example` | Variables AWS (à dupliquer en `.env`) |
| `.gitignore` | Exclut `.env` et le state Terraform |
| `terraform/main.tf` | Bucket S3 + table DynamoDB |
| `terraform/variables.tf` | Préfixe, région, owner |
| `terraform/outputs.tf` | Nom du bucket, ARN, etc. |

## Démarrage

```bash
cp .env.example .env
# Editer .env : coller votre AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, choisir un PROJECT_PREFIX unique

docker compose build
docker compose up -d tools

docker compose run --rm tools aws sts get-caller-identity
docker compose run --rm tools terraform -chdir=terraform init
docker compose run --rm tools terraform -chdir=terraform plan
docker compose run --rm tools terraform -chdir=terraform apply -auto-approve
```

## Validations

```bash
docker compose run --rm tools terraform -chdir=terraform output

docker compose run --rm tools aws s3 ls
docker compose run --rm tools aws dynamodb list-tables

# Tester un PUT objet
docker compose run --rm tools bash -lc 'echo hello > /tmp/h.txt && aws s3 cp /tmp/h.txt s3://$(terraform -chdir=terraform output -raw data_bucket_name)/hello.txt'

# Tester une insertion DynamoDB
docker compose run --rm tools bash -lc 'aws dynamodb put-item --table-name $(terraform -chdir=terraform output -raw items_table_name) --item "{\"pk\":{\"S\":\"item-1\"},\"value\":{\"N\":\"42\"}}"'

# Lire l'item
docker compose run --rm tools bash -lc 'aws dynamodb get-item --table-name $(terraform -chdir=terraform output -raw items_table_name) --key "{\"pk\":{\"S\":\"item-1\"}}"'
```

## Nettoyage (OBLIGATOIRE)

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down
```

Vérifiez ensuite dans la console AWS :

- `https://s3.console.aws.amazon.com/` — aucun bucket `tfaws-*-tp1-*`
- `https://us-east-1.console.aws.amazon.com/dynamodbv2/` — aucune table `tfaws-*-tp1-*`
