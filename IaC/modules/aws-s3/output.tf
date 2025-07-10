output "s3_datalake_bucket" {
  value = aws_s3_bucket.s3_datalake_bucket.bucket
}

output "s3_datalake_bucket_arn" {
  value = aws_s3_bucket.s3_datalake_bucket.arn
}

output "s3_datalake_bucket_id" {
  value = aws_s3_bucket.s3_datalake_bucket.id
}

output "s3_glue_script_bucket_id" {
  value = var.create_new_role_glue_job ? aws_s3_bucket.s3_glue_script_bucket[0].id : ""
}