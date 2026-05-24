variable "region" {
  description = "Région AWS."
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Préfixe global pour nommer toutes les ressources (ex. `tfaws-alice`)."
  type        = string
  default     = "tfaws-student"
}

variable "environment" {
  description = "Nom de l'environnement (dev/test/prod)."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Nom du propriétaire des ressources (utilisé en tag)."
  type        = string
  default     = "student"
}
