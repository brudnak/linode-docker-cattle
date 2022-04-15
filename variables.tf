# Linode Specific Variables
variable "linode_access_token" {
  type        = string
  description = "This is the Linode access token to create resources in Linode."
}


variable "linode_ssh_root_password" {
  type        = string
  description = "This value is what gets assigned as your ssh password to remote into the Linode instances."
}

# Rancher Specific Variables within Linode
variable "rancher_bootstrap_password" {
  type        = string
  description = "This is the bootstrap password that gets assigned to login to the Rancher UI."
}

# AWS Specific Variables
variable "aws_access_key" {
  type        = string
  description = "This is the AWS access key."
}

variable "aws_secret_key" {
  type        = string
  description = "This is the AWS secret key."
}

variable "aws_route53_fqdn" {
  type        = string
  description = "This should be the most used fully qualified domain name in the hosted zone in AWS Route 53."
}

# - Variable Shared Across Rancher, Linode, and AWS
# ---- rancher_version is injected into the docker run command to set the version of Rancer you want to use.
# ---- url_prefix_for_aws_route53 is used as a prefix when creating a record in AWS Route53.
# ---- linode_instance_label is what the Linode instance is named.
# ---- linode_set_system_hostname sets the Linode instance hostname, making it easy to know where you are when using ssh.
variable "rancher_instances" {
  type = list(object({
    rancher_version : string,
    url_prefix_for_aws_route53 : string,
    linode_instance_label : string,
    linode_set_system_hostname : string,
  }))
  description = "Rancher instances is a list/array of objects. Each object creates a Linode instance and AWS Route53 record."
}
