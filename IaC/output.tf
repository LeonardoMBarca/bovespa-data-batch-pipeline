output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = module.ec2.ec2_public_ip
}