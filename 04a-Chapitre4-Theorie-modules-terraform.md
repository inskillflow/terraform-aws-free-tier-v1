# Chapitre 4 — Théorie : modules Terraform

> **Objectif :** comprendre pourquoi on **modularise** du code Terraform, comment écrire un module local et comment le réutiliser.

---

## Sommaire

1. [Pourquoi des modules ?](#pourquoi)
2. [Anatomie d'un module](#anatomie)
3. [Modules locaux vs registry](#local-registry)
4. [Inputs et outputs](#io)
5. [Réutiliser un module plusieurs fois](#reuse)
6. [Bonnes pratiques](#bonnes-pratiques)
7. [Quiz](#quiz)
8. [Références](#references)

---

<a id="pourquoi"></a>

## 1. Pourquoi des modules ?

Sans module, votre `main.tf` grossit jusqu'à 500 lignes et :

- on duplique le même bloc S3 trois fois pour trois buckets,
- on ne sait plus quel bloc fait quoi,
- on a peur de modifier quoi que ce soit.

Avec des modules :

| Bénéfice | Description |
|---|---|
| **DRY** | Don't Repeat Yourself — un bucket décrit une fois, instancié N fois |
| **Lisibilité** | Le `main.tf` se lit comme un schéma d'architecture |
| **Réutilisabilité** | Le même module pour dev, test, prod |
| **Versionnage** | On peut épingler une version d'un module externe |

---

<a id="anatomie"></a>

## 2. Anatomie d'un module

Un module est **un dossier** contenant au minimum :

```text
modules/s3_bucket/
├── main.tf        ressources internes
├── variables.tf   inputs
└── outputs.tf     outputs
```

Optionnellement : `README.md`, `versions.tf`.

Exemple — module `s3_bucket` :

```hcl
# modules/s3_bucket/variables.tf
variable "bucket_name" {
  type        = string
  description = "Nom unique du bucket."
}

variable "tags" {
  type    = map(string)
  default = {}
}

# modules/s3_bucket/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

# modules/s3_bucket/outputs.tf
output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
```

Et au niveau du projet :

```hcl
# main.tf
module "data_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "tfaws-alice-data-${random_pet.suffix.id}"
  tags        = local.common_tags
}
```

---

<a id="local-registry"></a>

## 3. Modules locaux vs registry

| Type | `source = ...` | Quand |
|---|---|---|
| Local | `"./modules/s3_bucket"` | code interne à votre projet |
| Git | `"git::https://github.com/org/repo//path?ref=v1.2.0"` | partagé entre projets |
| Terraform Registry | `"terraform-aws-modules/s3-bucket/aws"` version `"x.y.z"` | module communautaire |

Pour ce cours : **uniquement modules locaux** (TP 4 et 5).

---

<a id="io"></a>

## 4. Inputs et outputs

Inputs : `variables.tf` du module → passés depuis le projet appelant.

Outputs : `outputs.tf` du module → accessibles depuis le projet appelant via `module.<nom>.<output>`.

Exemple :

```hcl
module "data_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "..."
}

resource "aws_iam_policy" "p" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${module.data_bucket.bucket_arn}/*"
    }]
  })
}
```

---

<a id="reuse"></a>

## 5. Réutiliser un module plusieurs fois

```hcl
module "data_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "tfaws-alice-data-${random_pet.suffix_data.id}"
  tags        = merge(local.common_tags, { Purpose = "data" })
}

module "logs_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "tfaws-alice-logs-${random_pet.suffix_logs.id}"
  tags        = merge(local.common_tags, { Purpose = "logs" })
}
```

Deux buckets, **un seul module**.

---

<a id="bonnes-pratiques"></a>

## 6. Bonnes pratiques

1. **Inputs minimaux** : ne demandez que ce qui change.
2. **Defaults raisonnables** : versioning, encryption, public access block → `true` par défaut.
3. **Tags fusionnés** : `merge(var.tags, { Module = "s3_bucket" })`.
4. **Outputs utiles** : ARN, ID, nom — pas plus.
5. **Pas de provider** dans le module : déclaré au niveau du projet.
6. **README.md** dans chaque module dès que vous le partagez.
7. **Tester** localement avant de versionner.

---

<a id="quiz"></a>

## 7. Quiz

1. Quels sont les **3 fichiers minimaux** d'un module Terraform ?
2. Comment référencer un module local ?
3. Comment accéder à un output d'un module ?
4. Pourquoi ne pas déclarer `provider` dans un module ?
5. Citer une raison de modulariser.

> Réponses : 1. `main.tf`, `variables.tf`, `outputs.tf`. 2. `source = "./modules/<nom>"`. 3. `module.<nom>.<output>`. 4. Pour permettre au projet appelant de choisir la config provider. 5. DRY, lisibilité, réutilisation, versionnage.

---

<a id="references"></a>

## 8. Références

- HashiCorp — Modules : https://developer.hashicorp.com/terraform/language/modules
- HashiCorp — Module composition : https://developer.hashicorp.com/terraform/language/modules/develop/composition
- Terraform Registry — modules AWS : https://registry.terraform.io/browse/modules?provider=aws

---

⬅ TP précédent : [`03b-Chapitre3-Pratique-ajouter-sqs.md`](03b-Chapitre3-Pratique-ajouter-sqs.md)  
➡ Pratique : [`04b-Chapitre4-Pratique-modules-terraform.md`](04b-Chapitre4-Pratique-modules-terraform.md)
