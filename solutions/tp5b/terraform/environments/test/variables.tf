variable "region" {
  description = "Région AWS."
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Préfixe global."
  type        = string
  default     = "tfaws-student"
}

variable "environment" {
  description = "Nom de l'environnement (dev/test)."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Propriétaire."
  type        = string
  default     = "student"
}
