variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "aws_key_name" {
  type        = string
  default     = "test-aws-jenkins-key-1-prod"
  description = "AWS key pair name"
}

variable "ssh_pkey_file" {
  type        = string
  default     = "/tmp/key/aws_key_1.pem.pub"
  description = "Public SSH key pair path"
}
 
variable "allowed_ports" {
  type        = set(string)
  default     = ["22", "8080"]
  description = "List of allowed ports for the security group"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "ami" {
  type        = string
  default     = "ami-0e1bed4f06a3b463d"
  description = "EC2 instance AMI"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-0bc772e515526bbe3"
  description = "AWS VPC ID"
}

variable "ec2_sgroup" {
  type        = string
  default     = "test_allow_jenkins_ip_22_8080_prod"
  description = "AWS EC2 security group"
}

variable "ec2_vol_type" {
  type        = string
  default     = "gp2"
  description = "AWS EC2 EBS volume type"
}

variable "ec2_vol_size" {
  type        = number
  default     = 8
  description = "AWS EC2 EBS volume size"
}

variable "ec2_inst_name" {
  type        = string
  default     = "ec2-test-terraform-prod-01"
  description = "AWS EC2 instance name tag"
}
