variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "lambda"
  type        = string
}

variable "principal_arns" {
  description = "A list of pricipal arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}

variable "force_destroy_state" {
  description = "Force destroy the 3s bucket containing state files?"
  default     = true
  type        = bool
}
