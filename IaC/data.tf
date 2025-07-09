data "aws_caller_identity" "current" {}

data "archive_file" "daily_lambda_bovespa_scripts" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-scripts/daily_lambda_bovespa"
  output_path = "${path.module}/lambda-scripts/daily_lambda_bovespa.zip"
}

data "archive_file" "lambda_glue_activation_scripts" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-scripts/lambda_glue_activation"
  output_path = "${path.module}/lambda-scripts/lambda_glue_activation.zip"
}