# Randomize OpenVPN port
resource "random_integer" "openvpn" {
  min = 1024
  max = 32765
}

# Randomize Wireguard port
resource "random_integer" "wireguard" {
  min = 32766
  max = 65535
}

# Get current IP address
data "http" "myip" {
  url = "https://ipecho.net/plain"
}

# Main security group, attached to EC2 instance
resource "aws_security_group" "this" {
  name        = var.name
  description = format("%s %s", var.name, "security group")

  tags = {
    Name = var.name
  }
}

# Allow to connect to randomized OpenVPN UDP port from anywhere
resource "aws_security_group_rule" "ingress_openvpn" {
  type              = "ingress"
  description       = "OpenVPN incoming"
  from_port         = random_integer.openvpn.result
  to_port           = random_integer.openvpn.result
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow to connect to randomized Wireguard UDP port from anywhere
resource "aws_security_group_rule" "ingress_wireguard" {
  type              = "ingress"
  description       = "Wireguard incoming"
  from_port         = random_integer.wireguard.result
  to_port           = random_integer.wireguard.result
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow to connect SSH from current IP
resource "aws_security_group_rule" "ingress_openssh" {
  type              = "ingress"
  description       = "SSH incoming"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
}

# Allow all outgoing traffic
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  description       = "Default outgoing"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}
