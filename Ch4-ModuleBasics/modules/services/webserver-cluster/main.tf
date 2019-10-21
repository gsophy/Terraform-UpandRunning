provider "aws" {
    region = "us-east-1"
}

data "aws_vpc" "default" {
    default =true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}


resource "aws_launch_configuration" "example" {
    image_id = "ami-04b9e92b5572fa0d1"
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance.id]

    user_data = data.template_file.user_data.rendered
    #             <<-EOF
    #             #!bin/bash
    #             echo "Hello World" > index.html
    #             echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
    #             echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
    #             nohup busybox httpd -f -p ${var.server_port} &
    #             EOF


# Required when using a launch configuration with an Auto-Scaling Group.
    lifecycle {
        create_before_destroy = true
    }
}

data "template_file" "user_data" {
   template = file("user-data.sh")

   vars = {
     server_port = var.server_port
     db_address = data.terraform_remote_state.db.outputs.address
     db_port = data.terraform_remote_state.db.outputs.port
   }
}


resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = var.min_size
    max_size = var.max_size

     tag {
        key = "Name"
        value = "${var.cluster_name}"
        propagate_at_launch = true
    }
}


resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-sg"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = var.any_protocol
        cidr_blocks = var.all_ips
    }
}

resource "aws_lb" "example" {
  name = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = var.http_port
  protocol = "HTTP"

# By default, return a simple 404: Page not Found page for requests that don't match a listener rule
  default_action {
      type = "fixed-response"

  fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}.alb-sg"

#  Allow inbound HTTP requests
  ingress {
      from_port = var.http_port
      to_port = var.http_port
      protocol = var.tcp_protocol
      cidr_blocks = var.all_ips
  }

#  Allow all outbound requests
  egress {
      from_port = var.any_port
      to_port = var.any_port
      protocol = var.any_protocol
      cidr_blocks = var.all_ips
  }
}


resource "aws_lb_target_group" "asg" {
  name = "${var.cluster_name}-asg-tg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

condition {
    field = "path-pattern"
    values = ["*"]
}

action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
    }
}

terraform {
    backend "s3" {
        bucket = "tf-state-bucket-gsophy"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
} 

data "terraform_remote_state" "db" {
  backend = "s3" 
    config = {
      bucket = var.db_remote_state_bucket
      key = var.db_remote_state_key
      region = "us-east-1"
    }
  }



