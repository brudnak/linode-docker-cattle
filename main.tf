terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

# The Linode provider. Providers are distributed separately from
# Terraform itself, and each provider has its own release cadence and version numbers.
# For more information about providers, see the following: https://www.terraform.io/language/providers#where-providers-come-from.
provider "linode" {
  token       = var.linode_access_token
  api_version = "v4beta"

}

# The AWS provider.
provider "aws" {
  region     = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Linode Instance Resource is how we create virtual machines in Linode.
# Resources are the most important element in the Terraform language.
# Each resource block describes one or more infrastructure objects
resource "linode_instance" "linode_instance" {

  # Using the count Meta-Arugment to create however many Linode virtual machines we want.
  # If a resource or module block includes a count argument whose value
  # is a whole number, Terraform will create that many instances,
  # more can be read about it here: https://www.terraform.io/language/meta-arguments/count.
  count     = length(var.rancher_instances)
  label     = var.rancher_instances[count.index].linode_name
  image     = "linode/ubuntu20.04"
  region    = "us-west"
  type      = "g6-standard-4"
  root_pass = var.linode_ssh_root_password

  # Creating an ssh connection with the Linode
  # instances that are being created.
  connection {
    type     = "ssh"
    user     = "root"
    password = var.linode_ssh_root_password
    # one takes a list, set, or tuple value with either zero or one elements.
    # If the collection is empty, one returns null. Otherwise, one returns the
    # first element. If there are two or more elements then one will return an error.
    # https://www.terraform.io/language/functions/one
    host = one(self.ipv4)
  }

  # Starting remote execution of terminal commands on the Linode
  # instances that have been created. This is running docker run
  # commands for Rancher with different versions.
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} rancher/rancher:${var.rancher_instances[count.index].version} --acme-domain ${var.rancher_instances[count.index].url}.${var.aws_route53_fqdn}"
    ]
  }
}

# The AWS Route53 Record Resource is how we are creating two records
# within the hosted zone so that we can test Rancher without running
# into self signed certificate issues.
resource "aws_route53_record" "aws_route53_record" {
  count   = length(var.rancher_instances)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.rancher_instances[count.index].url
  type    = "A"
  ttl     = "300"
  records = [linode_instance.linode_instance[count.index].ip_address]
}

# Data sources allow Terraform to use information defined outside of
# Terraform, defined by another separate Terraform configuration, or modified by functions.
# This specific data block is used for getting the zone ID in Rout53.
data "aws_route53_zone" "zone" {
  name = var.aws_route53_fqdn
}

# Output Section

output "linode_instance_ip_addresses" {
  value = [
    for linode_instance in linode_instance.linode_instance : "Linode IP address incase you need to SSH into it: ${linode_instance.ip_address}"
  ]
}

output "aws_route53_urls" {
  value = [
    for aws_route53_record in aws_route53_record.aws_route53_record : "your rancher URL: https://${aws_route53_record.fqdn}"
  ]
}

# Variable Section

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

# Variable Shared Across Rancher, Linode, and AWS
variable "rancher_instances" {
  type = list(object({
    version : string,
    url : string,
    linode_name : string,
  }))
  description = "Rancher instances is a list/array of objects. Each object creates a Linode instance and AWS Route53 record."
}
