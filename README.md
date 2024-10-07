# :cow: Linode Docker Cattle 

## Purpose of this Script

This terraform script is for Rancher QA to easily create two instances of docker installed Ranchers

1. A reproduction environment
2. A validation environment

:star: **The benefit is that it creates instances in Linode, along with a record in AWS Route53 so you can test without running into self signed certificate issues.** :star:

## This Repository Pairs Really Well with my Other Repository to Clean Up Linode Instances Automatically

https://github.com/brudnak/linode-daily-cleanup

All you need to de is make sure the tag looking to be deleted matches the name in your linode_tags variables in the `terraform.tfvars` here

## Setup Guide

1. Install Terraform on your local machine, instructions located here: [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Create a file named `terraform.tfvars` it will be at the same level as `main.tf`. This is where all of your secret variables will be placed. **MAKE SURE YOU DON'T TRACK IT WITH VERSION CONTROL**. It's listed in the `.gitignore` file, but be careful.
3. Your `terraform.tfvars` file will need to look like this, replace values with your own

```tf
# Variable Section

# Shared Variables Between Linode & AWS
label_prefix = "your-initials-must-be-less-than-or-equal-to-3-characters"

# Linode Specific Variables
linode_access_token      = "your-linode-api-token-you-create-on-linode"
linode_ssh_root_password = "whatever-password-you-want-to-ssh-into-your-linode-instance"

# The linode_tags variable isn't required but is helpful if you pair this repo, with my other repo to automatically cleanup your Linode instances based on tag names. That repository is located here. https://github.com/brudnak/linode-docker-cattle
linode_tags              = ["your-name-goes-here"]

# Rancher Specific Variables
rancher_bootstrap_password = "whatever-password-your-want-for-rancher"

dockerhub = "defaults to rancher/rancher but you may want rancherlabs etc"

# List/array or objects. However many objects you have in this list/array is how many Rancher/Linode instances will be created
rancher_instances = [{
  rancher_version : "v2.8.3",
  }, {
  rancher_version : "v2.9-head",
  }
]

# AWS Specific Variables
aws_access_key   = "whatever-your-aws-access-key-is"
aws_secret_key   = "whatever-your-aws-secret-key-is"

# Route53 fully qualified name should be in this format "something.something.something" the unique part will be added
# with random words from Terraform plus your 3 character label prefix variable from above
aws_route53_fqdn = "the-fully-qualified-domain-name-you-want-to-use-from-route53"
```

# Rancher Prime 🟦

Need to test with Rancher Prime?

Just set this field in `terraform.tfvars`:

```tf
dockerhub = "registry.rancher.com/rancher/rancher"
```

To: `registry.rancher.com/rancher/rancher`

### How to run 

After following the Setup Guide above

1. Run the following commands
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. It will ask you to verify what you're creating by typing `Yes` it's a good idea to check and make sure terraform is creating what you're expecting. 
6. You can watch the log output, at the very end you will get the IP address and URLs for the Rancher installs it created for you

### Output

You don't even need to login to Linode to get your IP address. It's displayed in the output from terraform like the following.

You can **ALWAYS** get these outputs by running the command

```shell
terraform output
```

```shell
Outputs:

aws_route53_urls = [
  "Rancher ULR: https://yourname1.something.something.com",
  "Rancher ULR: https://yourname2.something.something.com",
]
linode_instance_ip_addresses = [
  "Linode IP address: 0.0.0.0",
  "Linode IP address: 0.0.0.0",
]
```

### What Gets Created

4 Resources in total are created

- 2 Linode instances
- 2 AWS Route53 hosted zone records

### Possible Issues

- **SELF SIGNED CERT**: IF YOUR CHROME/BROWSER IS HAVING PROBLEMS, it may show the cert warning. If so, right click on Chrome in the launcher and click QUIT. Then start Chrome again and it should just work.

### How to Modify

If you want to create more than two Rancher instances. All you need to do is add another object to the array in your `terraform.tfvars` file.
The addition would look something like the following:

```tf
# Variable Section

# Shared Variables Between Linode & AWS
label_prefix = "your-initials-must-be-less-than-or-equal-to-3-characters"

# Linode Specific Variables
linode_access_token      = "your-linode-api-token-you-create-on-linode"
linode_ssh_root_password = "whatever-password-you-want-to-ssh-into-your-linode-instance"

# The linode_tags variable isn't required but is helpful if you pair this repo, with my other repo to automatically cleanup your Linode instances based on tag names. That repository is located here. https://github.com/brudnak/linode-docker-cattle
linode_tags              = ["your-name-goes-here"]

# Rancher Specific Variables
rancher_bootstrap_password = "whatever-password-your-want-for-rancher"

dockerhub = "defaults to rancher/rancher but you may want rancherlabs etc"

# List/array or objects. However many objects you have in this list/array is how many Rancher/Linode instances will be created
rancher_instances = [{
  rancher_version : "v2.9-head",
  }, {
  rancher_version : "v2.8-head",
  }, {
  rancher_version : "v2.7-head",
  }, {
  rancher_version : "v2.8.4",
  }
]

# AWS Specific Variables
aws_access_key   = "whatever-your-aws-access-key-is"
aws_secret_key   = "whatever-your-aws-secret-key-is"

# Route53 fully qualified name should be in this format "something.something.something" the unique part will be added
# with random words from Terraform plus your 3 character label prefix variable from above
aws_route53_fqdn = "the-fully-qualified-domain-name-you-want-to-use-from-route53"
```
