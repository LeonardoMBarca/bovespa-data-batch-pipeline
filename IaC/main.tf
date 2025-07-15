module "s3" {
  source = "./modules/aws-s3"

  account_id               = data.aws_caller_identity.current.account_id
  create_new_role_glue_job = var.create_new_role_glue_job
}

module "lambda" {
  source = "./modules/aws-lambda"

  account_id                             = data.aws_caller_identity.current.account_id
  create_new_role_daily_lambda_bovespa   = var.create_new_role_daily_lambda_bovespa
  name_role_daily_lambda_bovespa         = var.name_role_daily_lambda_bovespa
  create_new_role_lambda_glue_activation = var.create_new_role_lambda_glue_activation
  name_role_lambda_glue_activation       = var.name_role_lambda_glue_activation
  create_new_glue_job                    = var.create_new_glue_job
  name_glue_job                          = var.name_glue_job
  daily_lambda_bovespa_role_name         = module.iam.daily_lambda_bovespa_role_name
  lambda_glue_activation_role_name       = module.iam.lambda_glue_activation_role_name
  glue_job_name                          = module.glue.glue_job_name
  cloudwatch_event_rule_arn              = module.cloudwatch.cloudwatch_event_rule_arn
  s3_datalake_bucket_arn                 = module.s3.s3_datalake_bucket_arn
  s3_datalake_bucket_name                = module.s3.s3_datalake_bucket
  s3_script_bucket_name                  = module.s3.s3_script_bucket_name
  ecr_image_name                         = var.ecr_image_name
  ecr_image_tag                          = var.ecr_image_tag
}

module "glue" {
  source = "./modules/aws-glue"

  account_id               = data.aws_caller_identity.current.account_id
  create_new_glue_job      = var.create_new_glue_job
  create_new_role_glue_job = var.create_new_role_glue_job
  name_glue_job_role       = var.name_glue_job_role
  glue_job_role_name       = module.iam.glue_job_role_name
  s3_script_bucket_id      = module.s3.s3_script_bucket_name
  s3_datalake_bucket_id    = module.s3.s3_datalake_bucket_id
}

module "iam" {
  source = "./modules/aws-iam"

  account_id                             = data.aws_caller_identity.current.account_id
  s3_datalake_bucket                     = module.s3.s3_datalake_bucket
  create_new_role_daily_lambda_bovespa   = var.create_new_role_daily_lambda_bovespa
  create_new_role_lambda_glue_activation = var.create_new_role_lambda_glue_activation
  create_new_role_glue_job               = var.create_new_role_glue_job
  create_new_glue_job                    = var.create_new_glue_job
  name_glue_job                          = var.name_glue_job
  glue_job_name                          = module.glue.glue_job_name
}

module "cloudwatch" {
  source = "./modules/aws-cloudwatch"

  daily_lambda_bovespa_arn = module.lambda.daily_lambda_bovespa_arn
}

module "athena" {
  source = "./modules/aws-athena"

  account_id                     = data.aws_caller_identity.current.account_id
  s3_athena_query_results_bucket = module.s3.s3_athena_query_results_bucket_name
  database_name                  = module.glue.glue_database_name
}