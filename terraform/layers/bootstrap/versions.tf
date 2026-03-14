terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "retail-store-tf-state-eu-central-1"
    key    = "stage/bootstrap/terraform.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
}
