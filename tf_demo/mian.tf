terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.52.0"
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

provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  private_key = file(var.snowflake_private_key_path)
  role     = var.snowflake_role
  # region   = var.snowflake_region
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

resource "snowflake_database" "demo_db" {
  name    = "DEMO_DB"
  comment = "Database provisioned via Terraform"
}

resource "snowflake_database" "demo_clone" {
  name                  = "DEMO_DB_CLONE"
  comment               = "Clone of the demo database"
  from_database = "SF2512_DB"
}
