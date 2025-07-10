variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "create_new_role_glue_job" {
  description = "Option to choose whether to use an existing role or create one"
  type        = bool
}