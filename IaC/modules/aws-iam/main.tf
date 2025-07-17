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
          "arn:aws:s3:::${var.s3_datalake_bucket}",
          "arn:aws:s3:::${var.s3_datalake_bucket}/*"
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
        Resource = "arn:aws:glue:*:${var.account_id}:job/${var.create_new_glue_job ? var.glue_job_name : var.name_glue_job}"
      }
    ]
  })
}

resource "aws_iam_role" "glue_job_role" {
  count = var.create_new_role_glue_job ? 1 : 0

  name = "glue-s3-catalog-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "glue_job_policy" {
  count = var.create_new_role_glue_job ? 1 : 0

  name = "glue-s3-catalog-policy"
  role = aws_iam_role.glue_job_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "GlueLogs",
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      },
      {
        Sid : "S3AccessRawAndRefined",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource : [
          "arn:aws:s3:::${var.s3_datalake_bucket}",
          "arn:aws:s3:::${var.s3_datalake_bucket}/raw/*",
          "arn:aws:s3:::${var.s3_datalake_bucket}/refined/*"
        ]
      },
      {
        Sid : "GlueDataCatalogAccess",
        Effect : "Allow",
        Action : [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:CreatePartition",
          "glue:UpdatePartition",
          "glue:DeletePartition"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_profile_role" {
  count = var.create_new_ec2_profile_role ? 1 : 0

  name = "FirehosePutRecordRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "glue_job_policy" {
  count = var.create_new_role_glue_job ? 1 : 0

  name = "FirehosePutRecordPolicy"
  role = aws_iam_role.ec2_profile_role

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "kinesis_bitcoin" {
  name = "profile_for_ec2_instance"
  role = aws_iam_role.ec2_profile_role[0].name ? 1 : var.instance_profile_role_name
}