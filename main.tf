terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
  }
}

provider "aws" {
  profile = "AdministratorAccess-217127483231"
  region  = "us-east-2"
}