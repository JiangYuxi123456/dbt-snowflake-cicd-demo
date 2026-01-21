variable "snowflake_account" {
  description = "qz47466.ca-central-1.aws"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_private_key_path" {
  description = "the path of Snowflake private key (PEM, base64 or raw)"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role for provisioning"
  type        = string
  default     = "ACCOUNTADMIN"
}

