variable "table_name" {
  description = "Nom de la table DynamoDB."
  type        = string
}

variable "hash_key" {
  description = "Nom de la clé de partition."
  type        = string
  default     = "pk"
}

variable "hash_key_type" {
  description = "Type de la clé (S=String, N=Number, B=Binary)."
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST ou PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  description = "Tags à appliquer."
  type        = map(string)
  default     = {}
}
