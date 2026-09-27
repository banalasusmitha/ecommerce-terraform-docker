# Printed at the end of "terraform apply" (and any time with "terraform output")

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app.public_dns
}

output "frontend_url" {
  description = "Open this in your browser to see the frontend"
  value       = "http://${aws_instance.app.public_ip}"
}

output "frontend_url_dns" {
  description = "Same website, using the DNS name"
  value       = "http://${aws_instance.app.public_dns}"
}

output "backend_api_urls" {
  description = "Backend data, fetched through the frontend"
  value = {
    users    = "http://${aws_instance.app.public_ip}/api/users"
    products = "http://${aws_instance.app.public_ip}/api/products"
    orders   = "http://${aws_instance.app.public_ip}/api/orders"
    cart     = "http://${aws_instance.app.public_ip}/api/cart"
  }
}

output "ssh_command" {
  description = "Run this from the terraform folder to log in to the server"
  value       = "ssh -i ${trimsuffix(var.public_key_path, ".pub")} ubuntu@${aws_instance.app.public_ip}"
}
