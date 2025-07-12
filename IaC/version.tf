terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-bucket-bovespa-199246429486" # Altere para seu state bucket com o número da sua conta AWS
    key    = "infra/tfstate_file.tfstate"
    region = "us-east-1"
  }
}