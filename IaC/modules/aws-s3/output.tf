output "s3_datalake_bucket" {
  value = aws_s3_bucket.s3_datalake_bucket.bucket
}

output "stream_bucket_name" {
  value = aws_s3_bucket.s3_stream_bitcoin_bucket.bucket
}

output "s3_datalake_bucket_arn" {
  value = aws_s3_bucket.s3_datalake_bucket.arn
}

output "s3_datalake_bucket_id" {
  value = aws_s3_bucket.s3_datalake_bucket.id
}

output "s3_script_bucket_name" {
  value = var.create_new_role_glue_job ? aws_s3_bucket.s3_script_bucket[0].bucket : null
}

output "s3_athena_query_results_bucket_name" {
  value = aws_s3_bucket.s3_athena_query_results.bucket
}

output "backup_bitcoin_bucket_name" {
  value = aws_s3_bucket.backup_bitcoin_bucket_name.bucket
}

output "backup_bitcoin_bucket_arn" {
  value = aws_s3_bucket.backup_bitcoin_bucket_name.arn
}
output "s3_stream_bitcoin_bucket_name" {
  value = aws_s3_bucket.s3_stream_bitcoin_bucket.bucket
}
output "s3_stream_bitcoin_bucket_arn" {
  value = aws_s3_bucket.s3_stream_bitcoin_bucket.arn
}