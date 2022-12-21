variable "name" {
  type        = string
  description = "Project name"
  default     = "holtzman-effect"
}

# The directory will contain ssh keys for the EC2 instance and OpenVPN keys
# Produced artifacts (ssh keys, OpenVPN keys) will be available in this dir
variable "output_dir" {
  type        = string
  description = "Directory for artfacts"
  default     = "../_output"
}
