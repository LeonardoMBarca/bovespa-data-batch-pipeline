variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

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
  description = "Lambda Glue Activation Role Name"
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

variable "daily_lambda_bovespa_role_name" {
  description = "Daily Lambda Bovespa Role Name from IAM module"
  type        = string
}

variable "lambda_glue_activation_role_name" {
  description = "Lambda Glue Activation Role Name from IAM module"
  type        = string
}

variable "glue_job_name" {
  description = "Glue Job name from Glue module"
  type        = string
}

variable "cloudwatch_event_rule_arn" {
  description = "CloudWatch Event Rule ARN"
  type        = string
}

variable "s3_datalake_bucket_arn" {
  description = "S3 Datalake Bucket ARN"
  type        = string
}

variable "s3_datalake_bucket_name" {
  description = "S3 Datalake Bucket name"
  type        = string
}