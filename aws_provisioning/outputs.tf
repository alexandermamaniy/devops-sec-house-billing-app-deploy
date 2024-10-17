output "nat_instance_ip" {
  value = aws_instance.house_billing_nat_instance.public_ip
}

output "nginx_proxy_instance_ip" {
  value = aws_instance.house_billing_nginx_proxy_instance.public_ip
}

output "web_rest_api_instance_ip" {
  value = aws_instance.house_billing_web_rest_api_instance.public_ip
}
