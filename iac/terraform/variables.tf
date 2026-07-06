variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Name of your EC2 key pair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "your_ip" {
  description = "Your IP for SSH (e.g. 1.2.3.4/32). Use 0.0.0.0/0 to allow all."
  type        = string
  default     = "0.0.0.0/0"
}
