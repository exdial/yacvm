variable "output_dir" {
  type        = string
  description = "Directory for artfacts"
  default     = "out"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name"
  default     = "privatevpn"
}

variable "instance_name" {
  type        = string
  description = "The name of EC2 instance"
  default     = "privatevpn"
}
