variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "project_name" {
  description = "Prefix used in the Name tag of every resource"
  type        = string
  default     = "ecommerce"
}

variable "vpc_cidr" {
  description = "IP address range of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IP address range of the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance size (t3.micro is Free Tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "dockerhub_username" {
  description = "Your Docker Hub username - the images are pulled from <username>/<service>:<tag>"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]*$", var.dockerhub_username))
    error_message = "Set dockerhub_username in terraform.tfvars to your real Docker Hub username (lowercase)."
  }
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "v1"
}

variable "public_key_path" {
  description = "Public SSH key file (inside this terraform folder) used to log in to the EC2 instance"
  type        = string
  default     = "ecommerce-key.pub"
}

variable "ssh_allowed_cidr" {
  description = "Who may SSH to the server. 0.0.0.0/0 = anyone; better: your own IP, e.g. 49.37.10.20/32"
  type        = string
  default     = "0.0.0.0/0"
}
