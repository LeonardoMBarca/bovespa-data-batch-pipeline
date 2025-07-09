resource "aws_iam_role" "daily_lambda_bovespa_role" {
  count = var.create_new_role_daily_lambda_bovespa ? 1 : 0

  name = "lambda-s3-full-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "daily_lambda_bovespa_policy" {
  count = var.create_new_role_daily_lambda_bovespa ? 1 : 0

  name = "daily-lambda-bovespa-policy"
  role = aws_iam_role.daily_lambda_bovespa_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "AllowFullS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_datalake_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3_datalake_bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_glue_activation_role" {
  count = var.create_new_role_lambda_glue_activation ? 1 : 0

  name = "lambda-glue-activation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_glue_activation_policy" {
  count = var.create_new_role_lambda_glue_activation ? 1 : 0

  name = "lambda-glue-activation-policy"
  role = aws_iam_role.lambda_glue_activation_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "AllowStartGlueJob"
        Effect = "Allow"
        Action = [
          "glue:StartJobRun"
        ]
        Resource = "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:job/NOME_DO_JOB"
      }
    ]
  })
}
