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

locals {
  rancher_setups = {
    "repro-rancher-terraform" = { name = "repro-${var.your_name}-terraform", cmd = "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged -e CATTLE_BOOTSTRAP_PASSWORD=${var.my_bootstrap_password} rancher/rancher:${var.repro_version}" },
    "valid-rancher-terraform" = { name = "valid-${var.your_name}-terraform", cmd = "docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged -e CATTLE_BOOTSTRAP_PASSWORD=${var.my_bootstrap_password} rancher/rancher:${var.valid_version}" },
  }
}

# linode
resource "linode_instance" "rancher_machine" {

  # looping through each value in rancher_setups
  for_each = local.rancher_setups

  # what the linode instance will be named
  label     = each.value.name
  image     = "linode/ubuntu20.04"
  region    = "us-west"
  type      = "g6-standard-4"
  root_pass = var.root_pass

  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_pass
    # TODO: research one()
    # for some reason this only works with one()
    host     = one(self.ipv4)
  }

  provisioner "file" {
    source      = "scripts/setup.sh"
    # this setup.sh script is a bit pointless. it's only
    # running basic commands that could be executed in the 
    # remote-exec provisioner below. leaving it here for
    # an example though. 
    destination = "setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x setup.sh",
      "sudo ./setup.sh",
      each.value.cmd
    ]
  }
}

# token variable is your Linode access token
variable "token" {}    

# root_pass variable is the password that gets assigned to SSH into the Linode instance
variable "root_pass" {}             

# repro_version is what version of Rancher you want to reproduce an issue on e.g. "v2.6.3"
variable "repro_version" {}

# valid_version is what version of Rancher you want to validate an issue on e.g. "v2.6-head"
variable "valid_version" {}

# my_bootstrap_password is what gets assigned as your admin password for logging into the Rancher web UI
variable "my_bootstrap_password" {} 

# your_name is a unique value that gets inserted into your Linode instance label
variable "your_name" {}
