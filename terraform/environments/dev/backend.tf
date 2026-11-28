terraform {
  required_version = ">= 1.8.0"

  backend "s3" {
    bucket         = "sorobanerp-pfm-tfstate-us-east-2-366476833548"
    key            = "pfm-web-infra/dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "pfm-tfstate-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}
