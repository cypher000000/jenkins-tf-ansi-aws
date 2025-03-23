variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "aws_key_name" {
  type        = string
  default     = "test-aws-jenkins-key-1"
  description = "AWS key pair name"
}

variable "ssh_pkey_file" {
  type        = string
  default     = "/tmp/key/aws_key_1.pem.pub"
  description = "public SSH key pair path"
}
 
variable "allowed_port" {
  type        = number
  default     = 22
  description = "Allowed port for the security group"
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
  default     = "vpc-0e1bed4f06a3b463d"
  description = "AWS VPC ID"
}

variable "ec2_sgroup" {
  type        = string
  default     = "test_allow_jenkins_ip_22_build"
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
  default     = "ec2-test-terraform-build-01"
  description = "AWS EC2 instance name tag"
}
