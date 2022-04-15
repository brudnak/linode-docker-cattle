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
