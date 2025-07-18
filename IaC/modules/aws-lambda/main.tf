resource "aws_lambda_function" "daily_lambda_bovespa" {
  function_name = "daily-lambda-bovespa"

  package_type = "Image"
  image_uri    = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/${var.ecr_image_name}:${var.ecr_image_tag}"

  role        = "arn:aws:iam::${var.account_id}:role/${var.create_new_role_daily_lambda_bovespa == true ? var.daily_lambda_bovespa_role_name : var.name_role_daily_lambda_bovespa}"
  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      BUCKET_NAME = var.s3_datalake_bucket_name
      IBOV_URL    = "https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetDownloadPortfolioDay/eyJpbmRleCI6IklCT1YiLCJsYW5ndWFnZSI6InB0LWJyIn0="
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
      JOB_NAME    = var.create_new_glue_job ? var.glue_job_name : var.name_glue_job
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

resource "aws_lambda_function" "lambda_backup_bitcoin" {
  function_name = "bitcoin-backup-assync"

  package_type = "Image"
  image_uri    = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/${var.ecr_image_name_bitcoin}:${var.ecr_image_tag}"

  role        = "arn:aws:iam::${var.account_id}:role/${var.create_new_role_lambda_backup == true ? var.lambda_backup_role_name : var.role_lambda_backup_name}"
  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      BUCKET_NAME = var.s3_backup_bitcoin_bucket_name
    }
  }
}

resource "aws_lambda_permission" "bitcoin_backup_event" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_backup_bitcoin.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.event_bitcoin_arn
}

resource "aws_sqs_queue" "bitcoin_queue_stream" {
  name = "bitcoin-queue-stream-s3"
}

resource "aws_sqs_queue_policy" "default" {
  queue_url = aws_sqs_queue.bitcoin_queue_stream.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.bitcoin_queue_stream.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${var.s3_backup_bitcoin_bucket_name}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "s3_trigger_sqs_bitcoin" {
  bucket = var.s3_backup_bitcoin_bucket_name

  queue {
    queue_arn     = aws_sqs_queue.bitcoin_queue_stream.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "data/"
    # filter_suffix = ".parquet"
  }
  depends_on = [aws_sqs_queue_policy.default]
}