# Partial configuration.  The other settings (e.g. bucket, region, table) will be
# passed in from a file via -backend-config arguments to the 'terraform init'

terraform {
    backend "s3" {
        key = "partial-config/terraform.tfstate"
    }
}