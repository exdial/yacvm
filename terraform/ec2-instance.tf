# Lookup for the latest Ubuntu 18.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  # This filter depends on instance type you choose.
  # Example: the t4g instance type uses a Graviton processor,
  # so the architecture will be arm64. Whereas t3 instances use
  # Intel x86_64 processors, so the architecture will be amd64.
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  # Only HVM instances can launch TUN devices.
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical account
}

# Define EC2 instance
resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t4g.nano" # https://instances.vantage.sh/
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

  # see security-groups.tf
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  tags = {
    Name = var.name
  }

}
