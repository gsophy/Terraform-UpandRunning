provider "aws" {
    region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/webserver-cluster"
  
}

cluster_name = "webservers-stage"
db_remote_state_bucket = "tf-state-bucket-gsophy"
db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

instance_type = "t2.micro"
min_size = 2
max_size = 2

# Let's assume that we need to add a single Security Group rule
# to staging for testing purposes.  If we add it to the module, it'll
# get installed in all environments.  So, we add a resource
# for the security group rule to the Staging main.tf

# we can also reference the security group that was created
# in the staging environment.  

resource "aws_security_group_rule" "allow_testing_inbound" {
   type = "ingress"
   security_group_id = module.webserver_cluster.alb_security_group_id

   # the security_group_id value is a reference to the output
   # in the outputs.tf for the webserver_cluster module.

   from_port = 12345
   to_port = 12345
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
}
