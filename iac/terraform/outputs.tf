output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "Open this in your browser"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "SSH into the instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.web.public_ip}"
}
