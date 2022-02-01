variable "name" {
  type        = string
  description = "The name of application"
  default     = "holtzman-effect"
}

variable "output_dir" {
  type        = string
  description = "Directory for artfacts"
  default     = "../_output"
}
