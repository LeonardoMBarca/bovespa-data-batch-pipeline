variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "instance_profile_name" {
  description = "instance profile name"
  type        = string
}

variable "key_name" {
  description = "Nome do par de chaves SSH para acessar a instância EC2"
  type        = string
  default     = ""
}