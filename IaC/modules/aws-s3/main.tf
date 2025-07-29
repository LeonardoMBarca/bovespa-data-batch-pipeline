resource "aws_s3_bucket" "s3_datalake_bucket" {
  bucket        = "datalake-pregao-bovespa-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3_script_bucket" {
  count         = var.create_new_role_glue_job ? 1 : 0
  bucket        = "scripts-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3_athena_query_results" {
  bucket        = "athena-query-results-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3_stream_bitcoin_bucket" {
  bucket        = "bitcoin-streaming-data-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "backup_bitcoin_bucket_name" {
  bucket        = "backup-bitcoin-streaming-data-${var.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "glacier_backup_config" {
  bucket = aws_s3_bucket.backup_bitcoin_bucket_name.id

  rule {
    id     = "move-to-glacier"
    status = "Enabled"

    filter {
      prefix = "backup-data/"
    }

    transition {
      days          = 1
      storage_class = "GLACIER"
    }

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_object" "s3_glue_script_object" {
  count = var.create_new_role_glue_job ? 1 : 0

  bucket = aws_s3_bucket.s3_script_bucket[0].id
  key    = "glue/glue_script.py"
  source = "${path.module}/../../scripts/glue-script/glue_script.py"
  etag   = filemd5("${path.module}/../../scripts/glue-script/glue_script.py")
}