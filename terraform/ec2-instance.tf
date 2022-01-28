# Lookup AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group_rule" "ingress_openvpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 1337
  protocol          = "udp"
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_openssh" {
  type              = "ingress"
  from_port         = 0
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group" "this" {
  name        = var.name
  description = "The main application group"

  tags = {
    Name = var.name
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano" # https://ec2instances.info/
  key_name      = aws_key_pair.this.key_name

  root_block_device {
    encrypted = true
    # gp3 offers SSD-performance at a 20% lower
    # cost per GB than gp2 volumes
    volume_type = "gp3"
    volume_size = "8"
    tags = {
      Name = var.name
    }
  }

  security_groups = [
    aws_security_group.this.id
  ]

  tags = {
    Name = var.name
  }

}
