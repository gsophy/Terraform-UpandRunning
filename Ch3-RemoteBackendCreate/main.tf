provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-state-bucket-gsophy"

# Prevent accidental deletion of this s3 bucket
lifecycle {
    prevent_destroy = true
}

# Enable versioning so we can see the full revision history of
# our state file
versioning {
    enabled = true
}

# Enable server-side encryption by default
server_side_encryption_configuration {
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}

terraform {
    backend "s3" {
        bucket = "tf-state-bucket-gsophy"
        key = "global/s3/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
} 

output "s3_bucket_arn" {
    description = "the ARN of the .tfstate s3 state bucket"
    value = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
    description = "The name of the DynamoDB table"
    value = aws_dynamodb_table.terraform_locks.name
}