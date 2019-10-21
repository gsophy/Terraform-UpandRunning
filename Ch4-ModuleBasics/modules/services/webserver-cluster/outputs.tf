output "alb_dns_name" {
    value =aws_lb.example.dns_name
    description = "The domain name of the load balancer"
}
output "subnet_ids" {
  value = data.aws_subnet_ids.default.ids
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "asg_name" {
  value = aws_autoscaling_group.example.name
  description = "The name of the AutoScaling Group"
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "alb_security_group_id" {
  value = alb_security_group.alb.id
  description = "The security group ID associated with the Application Load Balancer"

}
