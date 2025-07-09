resource "aws_lambda_function" "daily_lambda_bovespa" {
  function_name = "daily_lambda_bovespa"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.create_new_role_daily_lambda_bovespa == true ? aws_iam_role.daily_lambda_bovespa_role[0].name : var.name_role_daily_lambda_bovespa}"
  handler       = "main.handler"
  runtime       = "python3.9"

  filename         = data.archive_file.daily_lambda_bovespa_scripts.output_path
  source_code_hash = data.archive_file.daily_lambda_bovespa_scripts.output_base64sha256
}

resource "aws_lambda_permission" "bovespa_lambda_allow_event" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_lambda_bovespa.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bovespa_event.arn
}

resource "aws_lambda_function" "lambda_glue_activation" {
  function_name = "lambda_glue_activation"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.create_new_role_lambda_glue_activation == true ? aws_iam_role.lambda_glue_activation_role[0].name : var.name_role_lambda_glue_activation}"
  handler       = "main.handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_glue_activation_scripts.output_path
  source_code_hash = data.archive_file.lambda_glue_activation_scripts.output_base64sha256
}

resource "aws_lambda_permission" "glue_lambda_allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_glue_activation"
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_datalake_bucket.arn
}