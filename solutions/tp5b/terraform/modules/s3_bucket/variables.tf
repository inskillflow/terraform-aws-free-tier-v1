variable "bucket_name" {
  description = "Nom du bucket (doit être globalement unique)."
  type        = string
}

variable "versioning_enabled" {
  description = "Activer le versioning."
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Activer les 4 blocs publics."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Algorithme SSE par défaut. AES256 ou aws:kms."
  type        = string
  default     = "AES256"
}

variable "tags" {
  description = "Tags à appliquer."
  type        = map(string)
  default     = {}
}
