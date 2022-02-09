# Linode Docker Cattle :cow:

## Purpose of this Script

This terraform script is for Rancher QA to easily create two instances of docker installed Ranchers

1. A reproduction environment
2. A validation environment

:star: **The benefit is that it creates instances in Linode, along with a record in AWS Route53 so you can test without running into self signed certificate issues.** :star:

## Setup Guide

1. Install Terraform on your local machine, instructions located here: [https://learn.hashicorp.com/tutorials/terraform/install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Create a file named `terraform.tfvars` it will be at the same level as `main.tf`. This is where all of your secret variables will be placed. **MAKE SURE YOU DON'T TRACK IT WITH VERSION CONTROL**. It's listed in the `.gitignore` file, but be careful.
3. Your `terraform.tfvars` file will need to look like this, replace values with your own

```tf
# Variable Section

# Linode Specific Variables
linode_access_token      = "generate-this-token-in-linode"
linode_ssh_root_password = "whatever-you-want"

# Rancher Specific Variables within Linode
rancher_bootstrap_password = "whatever-you-want"

# AWS Specific Variables
aws_access_key   = "generate-this-key-in-aws"
aws_secret_key   = "generate-this-key-in-aws"
aws_route53_fqdn = "look-up-the-most-used-hosted-zone-in-route53"


# Variable Shared Across Rancher, Linode, and AWS
rancher_instances = [{
  version : "v2.6.3",
  url : "whateveryouwant1",
  linode_name : "whateveryouwant1",
  },
  {
    version : "v2.6-head",
    url : "whateveryouwant2",
    linode_name : "whateveryouwant2",
}]

```
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

```tf
Outputs:

aws_route53_urls = [
  "your rancher ULR: https://yourname1.something.something.com",
  "your rancher ULR: https://yourname2.something.something.com",
]
linode_instance_ip_addresses = [
  "Linode IP address incase you need to SSH into it: 0.0.0.0",
  "Linode IP address incase you need to SSH into it: 0.0.0.0",
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
# Variable Shared Across Rancher, Linode, and AWS
rancher_instances = [{
  version : "v2.6.3",
  url : "whateveryouwant1",
  linode_name : "whateveryouwant1",
  },
  {
    version : "v2.6-head",
    url : "whateveryouwant2",
    linode_name : "whateveryouwant2",
},
 {
    version : "v2.5.11",
    url : "whateveryouwant3",
    linode_name : "whateveryouwant3",
}]
```