output "openvpn_port" {
  description = "OpenVPN port"
  value       = random_integer.this
}

output "openvpn_host" {
  description = "OpenVPN host"
  value       = aws_instance.public_ip
}
