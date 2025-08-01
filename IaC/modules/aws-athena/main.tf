resource "aws_athena_workgroup" "default" {
  name = "bovespa_workgroup"

  force_destroy = true

  configuration {
    result_configuration {
      output_location = "s3://${var.s3_athena_query_results_bucket}/"
    }
  }
}

resource "aws_athena_named_query" "daily_consul" {
  name        = "DailyConsultQuery"
  database    = var.database_name
  query       = <<EOF
  CREATE OR REPLACE VIEW "daily_bovespa" AS
  SELECT * 
  FROM gold_bovespa
  WHERE actual_date = current_date
  EOF
  description = "Query to fetch daily Bovespa data"
  workgroup   = aws_athena_workgroup.default.name
}

resource "aws_athena_named_query" "bitcoin_query" {
  name        = "BitcoinDataQuery"
  database    = var.database_name
  query       = <<EOF
  SELECT 
    pair,
    last as price,
    volume24h,
    var24h,
    time,
    timestamp_utc,
    type
  FROM bitcoin_ticker
  WHERE type = 'ticker_data'
  ORDER BY timestamp_utc DESC
  EOF
  description = "Query to fetch Bitcoin ticker data"
  workgroup   = aws_athena_workgroup.default.name
}