resource "aws_athena_workgroup" "default" {
  name = "bovespa_workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${var.s3_athena_query_results_bucket}/"
    }
  }
}

resource "aws_athena_named_query" "daily_consul" {
  name = "DailyConsultQuery"
  database = var.database_name
  query = <<EOF
  CREATE OR REPLACE VIEW "daily_bovespa" AS
  SELECT * 
  FROM gold_bovespa
  WHERE actual_date = current_date
  EOF
  description = "Query to fetch daily Bovespa data"
  workgroup = aws_athena_workgroup.default.name
}