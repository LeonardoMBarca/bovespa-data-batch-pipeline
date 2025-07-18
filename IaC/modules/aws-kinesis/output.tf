output "firehose_stream_name" {
  description = "Nome do Kinesis Firehose Delivery Stream"
  value       = aws_kinesis_firehose_delivery_stream.firehose_to_s3.name
}
