resource "aws_s3_bucket" "s3_datalake_bucket" {
  bucket = "datalake-pregao-bovespa"
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