# Solution — TP 5 (multi-environnements dev / test)

Solution exécutable correspondant à [`../../05b-Chapitre5-Pratique-environnements-dev-test.md`](../../05b-Chapitre5-Pratique-environnements-dev-test.md).

> **ARGENT :** vous allez déployer **deux fois** les mêmes ressources (dev + test). Toujours dans le Free Tier. **`terraform destroy` sur chacun des deux environnements** à la fin.

## Structure

```text
terraform/
├── modules/                 partagés (s3_bucket, dynamodb_table, sqs_queue)
└── environments/
    ├── dev/
    │   ├── provider.tf
    │   ├── variables.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars   (environment = "dev")
    └── test/
        ├── (identique a dev)
        └── terraform.tfvars   (environment = "test")
```

Chaque environnement a **son propre state** (`environments/<env>/terraform.tfstate`).

## Démarrage `dev`

```bash
cp .env.example .env
docker compose build
docker compose up -d tools

docker compose run --rm tools terraform -chdir=terraform/environments/dev init
docker compose run --rm tools terraform -chdir=terraform/environments/dev apply -auto-approve
```

Streamlit pointe sur `dev` par défaut :

```bash
docker compose up -d streamlit
```

Ouvrir http://localhost:8501

## Démarrage `test`

```bash
docker compose run --rm tools terraform -chdir=terraform/environments/test init
docker compose run --rm tools terraform -chdir=terraform/environments/test apply -auto-approve
```

Pour pointer Streamlit sur `test` :

```bash
TF_ENVIRONMENT=test docker compose up -d --force-recreate streamlit
```

## Nettoyage (deux fois !)

```bash
docker compose run --rm tools terraform -chdir=terraform/environments/dev  destroy -auto-approve
docker compose run --rm tools terraform -chdir=terraform/environments/test destroy -auto-approve
docker compose down
```

Vérifiez dans la console qu'il ne reste **aucun** bucket / table / queue préfixé `tfaws-*-tp5-*`.
