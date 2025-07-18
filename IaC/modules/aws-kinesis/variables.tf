variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "stream_bucket_arn" {
  description = "Name of stream bucket"
  type        = string
}

variable "create_new_firehose_role" {
  type = bool
}

variable "role_firehose" {
  type = string
}

variable "firehose_role" {
  type = string
}