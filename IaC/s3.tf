resource "aws_s3_bucket" "s3_datalake_bucket" {
  bucket = "datalake-pregao-bovespa-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_notification" "s3_trigger_lambda" {
  bucket = aws_s3_bucket.s3_datalake_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_glue_activation.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/"
    filter_suffix       = ".parquet"
  }

  depends_on = [aws_lambda_permission.glue_lambda_allow_s3]
}

resource "aws_s3_bucket" "s3_glue_script_bucket" {
  count  = var.create_new_role_glue_job ? 1 : 0
  bucket = "glue-script-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_object" "s3_glue_script_object" {
  count  = var.create_new_role_glue_job ? 1 : 0

  bucket = aws_s3_bucket.s3_glue_script_bucket[0].id
  key    = "glue_script.py"
  source = "${path.module}/glue-script/glue_script.py"
  etag   = filemd5("${path.module}/glue-script/glue_script.py")
}