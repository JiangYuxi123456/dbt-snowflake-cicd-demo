terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }


backend "s3" {
  bucket         = "sf512-bucket"
  key            = "terraform_states/terraform.tfstate"
  region         = "us-east-2"
  dynamodb_table = "tf-demo-locks"
  encrypt        = true
}
}

provider "aws" {
  region = "us-east-2"
}

resource "local_file" "hello" {
  filename = "hello.txt"
  content  = "How is everything going"
}

resource "aws_s3_object" "snowflake_data" {
  bucket = "sf512-bucket"
  key    = "snowflake_data/"  # the "folder"
  source = ""                # empty content
}
