variable "aws_region" {
  description = "AWS region to deploy us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "mern-app" {
  description = "mern-app"
  type        = string
  default     = "mern-app"
}

variable "instance_type" {
  description = "ubuntu"
  type        = string
  default     = "t2.micro"
}


variable "key_name" {
  description = "SSH key name for EC2"
  type        = string
  default     = "mern-key"
}

variable "vpc_id" {
  description = "VPC ID for deployment"
  type        = string
  default     = "vpc-0c7a0cde49cbccfe6"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the instances"
  type        = list(string)
  default     = [
    "subnet-0a1bf785ad89eeaf3",  # use1-az3 (us-east-1e)
    "subnet-02aa01034e8a693ca",  # use1-az5 (us-east-1f)
    "subnet-0bebf08b727bb7de3",  # use1-az1 (us-east-1d)
    "subnet-030f32eb8c0609559",  # use1-az6 (us-east-1c)
    "subnet-028b6a48887812023",  # use1-az2 (us-east-1a)
    "subnet-023317d38e86f14b6"   # use1-az4 (us-east-1b)
  ]
}

variable "desired_capacity" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}
