output "bastion_public_ip" {
  description = "Public IP of the bastion host - the only SSH entry point"
  value       = aws_eip.bastion.public_ip
}

output "app_private_ip" {
  description = "Private IP of the app server - not reachable directly from the internet, only via the bastion (SSH) or the ALB (HTTP)"
  value       = aws_instance.app.private_ip
}

output "alb_dns_name" {
  description = "Public URL for the app via the load balancer - this is the only public entry point to the website itself"
  value       = aws_lb.app.dns_name
}

output "rds_endpoint" {
  description = "RDS address (host only, no port)"
  value       = aws_db_instance.main.address
}
