data "archive_file" "daily_lambda_bovespa_scripts" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-scripts/daily-lambda-bovespa"
  output_path = "${path.module}/../../lambda-scripts/daily-lambda-bovespa.zip"
}

data "archive_file" "lambda_glue_activation_scripts" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-scripts/lambda-glue-activation"
  output_path = "${path.module}/../../lambda-scripts/lambda-glue-activation.zip"
}