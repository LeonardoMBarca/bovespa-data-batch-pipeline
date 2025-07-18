variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "instance_profile_name" {
  description = "instance profile name"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the instance"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file for SSH connection"
  type        = string
}