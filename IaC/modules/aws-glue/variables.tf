variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "create_new_glue_job" {
  description = "Option to choose whether to use an existing job or create one"
  type        = bool
}

variable "create_new_role_glue_job" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}

variable "name_glue_job_role" {
  description = "Glue Job Role Name"
  type        = string
}

variable "glue_job_role_name" {
  description = "Glue Job Role Name from IAM module"
  type        = string
}

variable "s3_script_bucket_id" {
  description = "S3 Glue Script Bucket ID"
  type        = string
}

variable "s3_datalake_bucket_id" {
  description = "S3 Datalake Bucket ID"
  type        = string
}