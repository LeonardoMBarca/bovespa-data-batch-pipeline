variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "s3_datalake_bucket" {
  description = "S3 Datalake Bucket Name"
  type        = string
}

variable "create_new_role_daily_lambda_bovespa" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "create_new_role_lambda_glue_activation" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "create_new_role_glue_job" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "create_new_glue_job" {
  description = "Option to choose whether to use an existing job or create one"
  type        = bool
}

variable "name_glue_job" {
  description = "Glue Job name"
  type        = string
}

variable "glue_job_name" {
  description = "Glue Job name from module"
  type        = string
}