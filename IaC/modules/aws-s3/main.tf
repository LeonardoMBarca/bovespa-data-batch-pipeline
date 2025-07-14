resource "aws_s3_bucket" "s3_datalake_bucket" {
  bucket = "datalake-pregao-bovespa-${var.account_id}"
}

resource "aws_s3_bucket" "s3_script_bucket" {
  bucket = "scripts-${var.account_id}"
}

resource "aws_s3_object" "s3_glue_script_object" {
  count = var.create_new_role_glue_job ? 1 : 0

  bucket = aws_s3_bucket.s3_script_bucket.id
  key    = "glue/glue_script.py"
  source = "${path.module}/../../glue-script/glue_script.py"
  etag   = filemd5("${path.module}/../../glue-script/glue_script.py")
}

resource "aws_s3_object" "s3_lambda_layer" {
  bucket = aws_s3_bucket.s3_script_bucket.id
  key = "lambda-bovespa/layer_env.zip"
  source = "${path.module}/../../lambda-layers/layer_env.zip"
  etag = filemd5("${path.module}/../../lambda-layers/layer_env.zip")
}