# Solution — TP 4 (refactor en modules Terraform)

Solution exécutable correspondant à [`../../04b-Chapitre4-Pratique-modules-terraform.md`](../../04b-Chapitre4-Pratique-modules-terraform.md).

> **ARGENT :** mêmes ressources que TP 3, Free Tier. `terraform destroy` à la fin.

## Structure

```text
terraform/
├── modules/
│   ├── s3_bucket/      versioning + public access block + SSE
│   ├── dynamodb_table/ PAY_PER_REQUEST par défaut
│   └── sqs_queue/      long polling + SSE managée
├── main.tf             instancie les 3 modules
├── outputs.tf
├── provider.tf
└── variables.tf
```

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

## Astuce

`terraform get` télécharge à nouveau les modules. Comme nos modules sont locaux, `terraform init` suffit.

## Nettoyage

```bash
docker compose run --rm tools terraform -chdir=terraform destroy -auto-approve
docker compose down
```
