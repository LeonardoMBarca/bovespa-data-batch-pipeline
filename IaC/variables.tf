variable "create_new_role_daily_lambda_bovespa" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "name_role_daily_lambda_bovespa" {
  description = "Daily Lambda Bovespa Role Name"
  type        = string
}

variable "create_new_role_lambda_glue_activation" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "name_role_lambda_glue_activation" {
  description = "Daily Lambda Bovespa Role Name"
  type        = string
}

variable "create_new_glue_job" {
  description = "Option to choose whether to use an existing job or create one"
  type        = bool
}

variable "name_glue_job" {
  description = "Glue Job name"
  type        = string
}

variable "create_new_role_glue_job" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "name_glue_job_role" {
  description = "Daily Lambda Bovespa Role Name"
  type        = string
}

variable "ecr_image_name" {
  description = "value of the ECR image name"
  type        = string
}

variable "ecr_image_tag" {
  description = "value of the ECR image tag"
  type        = string
}

variable "create_new_ec2_profile_role" {
  description = "Option to choose whether to use an existing instance profile or create one"
  type        = bool
}

variable "instance_profile_role_name" {
  description = "Instance profile name"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to the private key file for SSH connection"
  type        = string
  default     = ""
}