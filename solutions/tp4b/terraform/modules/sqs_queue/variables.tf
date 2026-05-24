variable "queue_name" {
  description = "Nom de la queue."
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout en secondes."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Rétention des messages."
  type        = number
  default     = 86400
}

variable "receive_wait_time_seconds" {
  description = "Long polling : 0 (short) à 20 (long)."
  type        = number
  default     = 20
}

variable "sse_enabled" {
  description = "Activer SSE managée par SQS."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer."
  type        = map(string)
  default     = {}
}
