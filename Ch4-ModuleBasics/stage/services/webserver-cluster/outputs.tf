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

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}
