resource "aws_lambda_layer_version" "bovespa_layer" {
  layer_name = "bovespa_env"
  compatible_runtimes = ["python3.11"]

  s3_bucket = var.s3_script_bucket_name
  s3_key = "lambda-bovespa/layer_env.zip"
  
  depends_on = [var.s3_lambda_layer_object]
}

resource "aws_lambda_function" "daily_lambda_bovespa" {
  function_name = "daily-lambda-bovespa"
  role          = "arn:aws:iam::${var.account_id}:role/${var.create_new_role_daily_lambda_bovespa == true ? var.daily_lambda_bovespa_role_name : var.name_role_daily_lambda_bovespa}"
  handler       = "main.handler"
  runtime       = "python3.11"

  filename         = data.archive_file.daily_lambda_bovespa_scripts.output_path
  source_code_hash = data.archive_file.daily_lambda_bovespa_scripts.output_base64sha256

  layers = [aws_lambda_layer_version.bovespa_layer.arn]

    environment {
    variables = {
      BUCKET_NAME = var.s3_datalake_bucket_name
      IBOV_URL = "https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetDownloadPortfolioDay/eyJpbmRleCI6IklCT1YiLCJsYW5ndWFnZSI6InB0LWJyIn0="
    }
  }
}

resource "aws_lambda_permission" "bovespa_lambda_allow_event" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_lambda_bovespa.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.cloudwatch_event_rule_arn
}

resource "aws_lambda_function" "lambda_glue_activation" {
  function_name = "lambda-glue-activation"
  role          = "arn:aws:iam::${var.account_id}:role/${var.create_new_role_lambda_glue_activation == true ? var.lambda_glue_activation_role_name : var.name_role_lambda_glue_activation}"
  handler       = "main.handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_glue_activation_scripts.output_path
  source_code_hash = data.archive_file.lambda_glue_activation_scripts.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = var.s3_datalake_bucket_name
      JOB_NAME = var.create_new_glue_job ? var.glue_job_name : var.name_glue_job
    }
  }
}

resource "aws_lambda_permission" "glue_lambda_allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_glue_activation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_datalake_bucket_arn
}

resource "aws_s3_bucket_notification" "s3_trigger_lambda" {
  bucket = var.s3_datalake_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_glue_activation.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/"
    filter_suffix       = ".parquet"
  }

  depends_on = [aws_lambda_permission.glue_lambda_allow_s3]
}