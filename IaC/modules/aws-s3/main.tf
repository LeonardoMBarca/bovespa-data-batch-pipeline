resource "aws_s3_bucket" "s3_datalake_bucket" {
  bucket = "datalake-pregao-bovespa-${var.account_id}"
}

resource "aws_s3_bucket" "s3_script_bucket" {
  count  = var.create_new_role_glue_job ? 1 : 0
  bucket = "scripts-${var.account_id}"
}

resource "aws_s3_bucket" "s3_athena_query_results" {
  bucket = "athena-query-results-${var.account_id}"
}

resource "aws_s3_object" "s3_glue_script_object" {
  count = var.create_new_role_glue_job ? 1 : 0

  bucket = aws_s3_bucket.s3_script_bucket[0].id
  key    = "glue/glue_script.py"
  source = "${path.module}/../../glue-script/glue_script.py"
  etag   = filemd5("${path.module}/../../glue-script/glue_script.py")
}