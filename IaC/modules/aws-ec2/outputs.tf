output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.bitcoin_ingestor.public_ip
}