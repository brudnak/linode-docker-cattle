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

variable "linode_tags" {
  type        = list
  description = "Tags to add to the Linode instance."
}

variable "label_prefix" {
  type = string
  description = "The value added to the random pet name to associate it with yourelf. Shoud be maximum 3 characters for your initials."

    validation {
    condition     = length(var.label_prefix) <= 3
    error_message = "The label prefix should not be any longer than 3 characters for your initials."
  }
}

variable "rancher_instances" {
  type = list(object({
    rancher_version : string,
  }))
  description = "Rancher instances is a list/array of objects. Each object creates a Linode instance and AWS Route53 record."
}
