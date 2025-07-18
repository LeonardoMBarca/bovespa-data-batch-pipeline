resource "aws_kinesis_firehose_delivery_stream" "firehose_to_s3" {
  name        = "bitcoin-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = "arn:aws:iam::${var.account_id}:role/${var.create_new_firehose_role == true ? var.firehose_role : var.role_firehose}"
    bucket_arn         = var.stream_bucket_arn
    compression_format = "UNCOMPRESSED"
    buffering_size     = 1
    buffering_interval = 60

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/bitcoin-firehose"
      log_stream_name = "S3Delivery"
    }
  }
}
