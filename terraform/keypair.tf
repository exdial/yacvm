resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "this" {
  filename             = "${var.output_dir}/${var.name}.pem"
  file_permission      = "0600"
  directory_permission = "0700"
  sensitive_content    = tls_private_key.this.private_key_pem
}

resource "aws_key_pair" "this" {
  key_name   = var.name
  public_key = tls_private_key.this.public_key_openssh
}
