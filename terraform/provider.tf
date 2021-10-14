terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "sun-terraform-state"
    region = "ap-northeast-1"
    key = "agqr-program-guide"
    encrypt = false
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
