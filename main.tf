terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
  }
  backend "s3" {
    bucket = "eric-iac"
    key    = "state/terraform.tfstate"
    region = "us-east-2"
  }

}

provider "aws" {
  # profile = "AdministratorAccess-217127483231"
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "eric-iac"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = "eric-iac"

  versioning_configuration {
    status = "Enabled"
  }
}