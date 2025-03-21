terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.0"
    }
  }
  backend "s3" {
    bucket       = ""
    key          = ""
    region       = ""
    encrypt      = ""
    use_lockfile = ""
  }

}
provider "aws" {
  region = var.aws_region
}

data "http" "jenkins_public_ip" {
  url = "http://checkip.amazonaws.com"
}

resource "aws_key_pair" "deployer" {
  key_name   = var.aws_key_name
  public_key = file(var.ssh_pkey_file)
}

resource "aws_security_group" "allow_jenkins_ip" {
  name        = var.ec2_sgroup
  description = "Test security group with jenkins ip on 22"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.ec2_sgroup
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_jenkins_ip_22_8080" {
  for_each = var.allowed_ports

  security_group_id = aws_security_group.allow_jenkins_ip.id
  cidr_ipv4         = "${chomp(data.http.jenkins_public_ip.response_body)}/32"
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_jenkins_ip.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
 
resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids      = [aws_security_group.allow_jenkins_ip.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = var.ec2_vol_type
    volume_size           = var.ec2_vol_size
    delete_on_termination = true
  }

  key_name  = aws_key_pair.deployer.id

  tags = {
    Name = var.ec2_inst_name
  }
}

output "aws_instance_public_dns" {
  value = aws_instance.instance.public_ip
}

output "ip_addr_for_sec_group" {
  value = chomp(data.http.jenkins_public_ip.response_body)
}
