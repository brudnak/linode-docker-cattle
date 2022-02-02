terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  token       = var.token
  api_version = "v4beta"
}



# linode
resource "linode_instance" "rancher_machine" {
  label     = var.instance_name
  image     = "linode/ubuntu20.04"
  region    = "us-west"
  type      = "g6-standard-4"
  root_pass = var.root_pass

  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_pass
    host     = one(linode_instance.rancher_machine.ipv4)
  }

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x setup.sh",
      "sudo ./setup.sh",
      "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged -e CATTLE_BOOTSTRAP_PASSWORD=${var.my_bootstrap_password} rancher/rancher:${var.rancher_version}"
    ]
  }
}

output "ipv4" {
  value       = one(linode_instance.rancher_machine.ipv4)
  description = "The IP address of the Linode instance that was created. The Rancher bootstrap password was set in the .tfvars file. So there is no need to SSH into the server and run docker commands to get the password."
}

# variables

# Linode access token
variable "token" {}

# Root password for the Linode instance
variable "root_pass" {}

# Setting our own bootstrap password for Rancher
variable "my_bootstrap_password" {}

# Rancher version set like the following "v2.6-head" in tfvars
variable "rancher_version" {}

# Name the Linode instance receives
variable "instance_name" {

}
