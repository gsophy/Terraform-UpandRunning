provider "aws" {
    region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}


resource "aws_instance" "example" {
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!bin/bash
                echo "Hello World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    tags = {
        Name = "terraform-example"
        application_code = "xxx"
        application_name = "application x"
    }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

output "external_ip" {
    value = aws_instance.example.public_ip
    description = "The Public IP address of the web server"
}
output "external_dns_name" {
  value = aws_instance.example.public_dns
  description = "The external DNS name of the web server"
}

