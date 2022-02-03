# linode-docker-cattle

### Using This Script

To make this script work you'll need to create a `terraform.tfvars` file within the project. Make sure this file does not end up getting tracked in version control.

### What does it do?

Creates two instances in Linode with a different Rancher version on each. This is to quickly create reproduction and validation environments.

### Variables you'll need in your terraform.tfvars file

1. `token` : token variable is your Linode access token
2. `root_pass` : root_pass variable is the password that gets assigned to SSH into the Linode instance
3. `repro_version` : repro_version is what version of Rancher you want to reproduce an issue on e.g. "v2.6.3"    
4. `valid_version` : valid_version is what version of Rancher you want to validate an issue on e.g. "v2.6-head" 
5. `my_bootstrap_password` : my_bootstrap_password is what gets assigned as your admin password for logging into the Rancher web UI
6. `your_name` : your_name is a unique value that gets inserted into your Linode instance label

It should look like the following:

```tf
token                 = "your-super-secret-linode-token-goes-here"
root_pass             = "this-password-is-to-shh-into-your-linode"
repro_version         = "v2.6.3"
valid_version         = "v2.6-head"
my_bootstrap_password = "this-is-the-password-to-login-as-admin-in-rancher-ui"
your_name             = "andy"
```

### How to run 

1. Download the code
2. Create your `terraform.tfvars` file with the above fields
3. Now run the following commands
    1. `terraform init`
    2. `terraform apply`
    3. It will ask you to type `Yes` to confirm what you will be creating

### What's next?

I want to make this better by adding functionality where it creates a record in our AWS Route 53 hosted zone. And update the docker command to be something like this.

```shell
docker run -d -p 80:80 -p 443:443 --restart=no --privileged rancher/rancher:v2.6.3 --acme-domain your-domain-goes-here
```

`--acme-domain your-domain-goes-here`

This way we can avoid running into issues with self signed certs while testing.