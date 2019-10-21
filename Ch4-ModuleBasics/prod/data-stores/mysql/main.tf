provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "example_database"
  username = "admin"

  password = var.db_password

# Additional settings.  Must be included so the resources can be destroyed.
final_snapshot_identifier = "prefix-name"
skip_final_snapshot = true
}

terraform {
    backend "s3" {
        bucket = "tf-state-bucket-gsophy"
        key = "prod/data-stores/mysql/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}
