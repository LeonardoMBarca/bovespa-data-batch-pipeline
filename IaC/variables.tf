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