# For the db_password input variable, here's how you 
# can set the TF_VAR_db_password environment variable
# on Linux/MacOS systems:

# $  export TF_VAR_db_password ="(YOUR_DB_PASSWORD)"
# $ terraform apply

# note the space before the export command to prevent
# the secret from being stored on disk in your bash 
# history

# Later we'll also learn about using a file like 
# secrets.tfvars to maintain sensitive passwords

variable "db_password" {
  description = "The password for the database"
  type = string
}

