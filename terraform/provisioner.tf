resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      ansible_host                 = aws_instance.this.public_ip,
      ansible_port                 = "22",
      ansible_user                 = "ubuntu",
      ansible_ssh_private_key_file = "${var.output_dir}/${var.name}.pem"
    }
  )
  filename = "${var.output_dir}/inventory"
}
