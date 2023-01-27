terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.29.4"
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
  token = var.linode_access_token
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
  label     = var.rancher_instances[count.index].linode_instance_label
  image     = "linode/ubuntu20.04"
  region    = "us-west"
  type      = "g6-standard-6"
  root_pass = var.linode_ssh_root_password
  tags      = var.linode_tags

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
      "sudo curl https://releases.rancher.com/install-docker/20.10.sh | sh",
      "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} rancher/rancher:${var.rancher_instances[count.index].rancher_version} --acme-domain ${var.rancher_instances[count.index].url_prefix_for_aws_route53}.${var.aws_route53_fqdn}",
    ]
  }
}

# The AWS Route53 Record Resource is how we are creating two records
# within the hosted zone so that we can test Rancher without running
# into self signed certificate issues.
resource "aws_route53_record" "aws_route53_record" {
  count   = length(var.rancher_instances)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.rancher_instances[count.index].url_prefix_for_aws_route53
  type    = "A"
  ttl     = "60"
  records = [linode_instance.linode_instance[count.index].ip_address]
}

# Data sources allow Terraform to use information defined outside of
# Terraform, defined by another separate Terraform configuration, or modified by functions.
# This specific data block is used for getting the zone ID in Rout53.
data "aws_route53_zone" "zone" {
  name = var.aws_route53_fqdn
}
