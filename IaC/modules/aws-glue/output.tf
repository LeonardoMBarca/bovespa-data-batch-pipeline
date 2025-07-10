output "glue_job_name" {
  value = var.create_new_glue_job ? aws_glue_job.glue_bovespa_processing[0].id : ""
}