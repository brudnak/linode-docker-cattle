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

provider "linode" {
  token       = var.linode_access_token
  api_version = "v4beta"
}

# local variables used accross creation of resources in Linode & AWS
locals {
  configuration_buckets = {
    "bucket_1" = {

      linode_label = "repro-${var.your_name}-terraform",

      linode_region = "us-west",

      docker_run_rancher_command = <<EOF

    docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged \
    -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} \
    rancher/rancher:${var.rancher_reproduction_version} \
    --acme-domain ${var.your_name}-${var.rancher_reproduction_version}.${var.qa_aws_route53_hosted_zone}
    
    EOF

      name_appended_to_aws_route_53_hosted_zone = "${var.your_name}-${var.rancher_reproduction_version}"

    },

    "bucket_2" = {


      linode_label = "valid-${var.your_name}-terraform",

      linode_region = "us-west"

      docker_run_rancher_command = <<EOF

    docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged \
    -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} \
    rancher/rancher:${var.rancher_validation_version} \
    --acme-domain ${var.your_name}-${var.rancher_validation_version}.${var.qa_aws_route53_hosted_zone}
    
    EOF

      name_appended_to_aws_route_53_hosted_zone = "${var.your_name}-${var.rancher_validation_version}"
    },
  }
}


resource "linode_instance" "li" {

  # looping through each bucket to get differnt docker commands and other various data
  for_each = local.configuration_buckets

  label     = each.value.linode_label
  image     = "linode/ubuntu20.04"
  region    = each.value.linode_region
  type      = "g6-standard-4"
  root_pass = var.linode_ssh_root_password

  connection {
    type     = "ssh"
    user     = "root"
    password = var.linode_ssh_root_password
    host     = one(self.ipv4)
  }

  # this file provisioner isn't really needed but is left as an example
  # all it does is update and install docker
  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "setup.sh"
  }

  # this remote-exec provisioner is executing the file from above and running a different docker run
  # command on each Linode instance, installing two different versions of Rancher
  provisioner "remote-exec" {
    inline = [
      "chmod u+x setup.sh",
      "sudo ./setup.sh",
      each.value.docker_run_rancher_command
    ]
  }
}

# this output is outputting the ip addresses for the linode 
# instances incase you need to ssh into them for logs etc.
output "linode_instance_ip_addresses" {
  value = [
    for li in linode_instance.li : "Linode IP address incase you need to SSH into it: ${li.ip_address}"
  ]
}

# this outout is the route53 urls, this way
# you don't need to log into any cloud service
# to start testing Rancher
output "aws_route53_urls" {
  value = [
    for www in aws_route53_record.www : "your rancher ULR: https://${www.fqdn}"
  ]
}

provider "aws" {
  region     = "us-east-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# this is getting the ID for our most used hosted zone
data "aws_route53_zone" "zone" {
  name = var.qa_aws_route53_hosted_zone
}


resource "aws_route53_record" "www" {

  # looping through our buckets to create two
  # AWS Route53 records, one for each Linode instance
  for_each = local.configuration_buckets

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = each.value.name_appended_to_aws_route_53_hosted_zone
  type    = "A"
  ttl     = "1209600"
  records = [linode_instance.li[each.key].ip_address]
}

variable "linode_access_token" {}
variable "linode_ssh_root_password" {}
variable "rancher_reproduction_version" {}
variable "rancher_validation_version" {}
variable "rancher_bootstrap_password" {}
variable "your_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "qa_aws_route53_hosted_zone" {}
