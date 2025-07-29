resource "aws_glue_catalog_table" "bitcoin_data" {
  name          = "bitcoin_ticker"
  database_name = aws_glue_catalog_database.refined_data.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://bitcoin-streaming-data-${var.account_id}/bitcoin-data/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "pair"
      type = "string"
    }

    columns {
      name = "last"
      type = "double"
    }

    columns {
      name = "volume24h"
      type = "double"
    }

    columns {
      name = "var24h"
      type = "double"
    }

    columns {
      name = "time"
      type = "string"
    }

    columns {
      name = "timestamp_utc"
      type = "string"
    }

    columns {
      name = "type"
      type = "string"
    }
  }
}