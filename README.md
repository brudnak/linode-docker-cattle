# linode-docker-cattle

### Using This Script

To make this script work you'll need to create a `terraform.tfvars` file within the project. Make sure this file does not end up getting tracked in version control.

### Variables you'll need in tfvars

1. `token` : This is your Linode access token
2. `root_pass` : Root password that you'll need if you want to SSH into the Linode instance
3. `rancher_version` : Rancher version that you want to use in a format with `v` like the following `v2.6-head`
4. `my_bootstrap_password` : Initial bootstrap password that you'll want to login to Rancher with
5. `instance_name` : Name you'd like the Linode instance to have

It should look like the following:

```tf
token                 = "your-linode-token-goes-here"
root_pass             = "root-password-that-you-want-to-generate"
rancher_version       = "v2.6-head"
my_bootstrap_password = "bootstrap-password-to-login-rancher-with"
instance_name         = "name-of-your-linode-instance"
```