resource "aws_glue_job" "glue_bovespa_processing" {
  count              = var.create_new_glue_job ? 1 : 0

  name              = "glue-bovespa-data-processing"
  role_arn          = "arn:aws:iam::${var.account_id}:role/${var.create_new_role_glue_job == true ? var.glue_job_role_name : var.name_glue_job_role}"
  glue_version      = "5.0"
  max_retries       = 0
  timeout           = 2880
  number_of_workers = 2
  worker_type       = "G.1X"
  execution_class   = "STANDARD"

  command {
    script_location = var.create_new_role_glue_job ? "s3://${var.s3_glue_script_bucket_id}/glue_script.py" : "s3://glue-script-${var.account_id}/glue_script.py"
    name            = "glueetl"
    python_version  = "3.9"
  }

  default_arguments = {
    "--TempDir" = var.create_new_role_glue_job ? "s3://${var.s3_glue_script_bucket_id}/glue-temp-dir/" : "s3://glue-script-${var.account_id}/glue-temp-dir/"
    "--job-language" = "python"
    "--BUCKET_NAME" = "${var.s3_datalake_bucket_id}"
    "--DATABASE_NAME" = aws_glue_catalog_database.refined_data.name
    "--enable-metrics" = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog" = "true"
  }
}

resource "aws_glue_catalog_database" "refined_data" {
    name = "refined_bovespa_data"
  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}


