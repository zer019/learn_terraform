# 
# This module contains resources relevant to the instantiation of of compute resources
# and relies on some information from the VPC module.
# 

# Minimum requirement select an AMI and instance type
# documentation on this resource https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# data "aws_ami" is declaring a var that contains information about the most recent AMI for ubuntu 20.04 Server, published by Canonical
# this allows for dynamic allocation of the AMI id when creating the resource webserver, if this is desired.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create ec2 resource using the AMI previously discovered of type t2.micro
# Assign a public IP
# Use the user_data to make some configuration changes on the instance and present the website.
# Better way to do index.html would be s3 sync? Definitely for a larger website.
resource "aws_instance" "webserver" {
  ami             = data.aws_ami.ubuntu.id #from aws_ami obtained above
  instance_type   = "t2.micro"
  security_groups = ["${var.tf_sg_id}"]
  subnet_id       = "${var.tf_subnet_id}"
  key_name        = "N. Virginia"
  associate_public_ip_address = true
  user_data = "${file(".\\ec2\\webserver_setup.sh")}"
  lifecycle {
    ignore_changes = [
      ami,
      tags,
      security_groups
    ]
  }
  tags = {
    "name" = "terraform"
  }
}

# Output the web server IP to accelerate connecting to check services and updating the DNS record
# Looks like it may be possible to user google provider to do the DNS record maintenance but that
# is outside the scope of this project, for now.
output "Public_ips" {
  value = aws_instance.webserver.public_ip
}