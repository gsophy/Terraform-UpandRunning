provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-example"
        application_code = "xxx"
        application_name = "application x"
    }
}