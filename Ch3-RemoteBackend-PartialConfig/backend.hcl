# backend.hcl: reference on page 86
        region = "us-east-1"
        bucket = "tf-state-bucket-gsophy"
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true