variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "s3_athena_query_results_bucket" {
  description = "S3 bucket for Athena query results"
  type        = string
}

variable "database_name" {
  description = "Name of the Athena database"
  type        = string
}