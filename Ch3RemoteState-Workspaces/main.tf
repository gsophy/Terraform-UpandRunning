provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami = "ami-0b69ea66ff7391e80"
    instance_type = "t2.micro"
}

terraform {
    backend "s3" {
        region = "us-east-1"
        bucket = "tf-state-bucket-gsophy"
        key = "workspaces-example/terraform.tfstate"
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}