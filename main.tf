# TODO:
# Install apache and create simple web page on EC2 instance

# ! use depends_on to make sure things are built in order of reference to other resources

# Specify the AWS CLI credentials to be used
# Need to see if there is a way to leverage AWS Secrets Manager on this step.
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "C:\\Users\\Admin\\.aws\\credentials"
  profile                 = "Personal-us-east-1"
}

# Create a VPC for this project
resource "aws_vpc" "terraform" {
    cidr_block = "172.16.0.0/16"

    tags = {
      "name" = "terraform"
    }
}

# Create a subnet for our server(s)
resource "aws_subnet" "webservers" {
    vpc_id = aws_vpc.terraform.id
    cidr_block = "172.16.24.0/24"
    availability_zone = "us-east-1a"

    tags = {
      "name" = "terraform"
    }

    depends_on = [
      aws_vpc.terraform
    ]
}

# Add internet gateway in VPC
resource "aws_internet_gateway" "terraformigw" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    "name" = "terraform"
  }

  depends_on = [
    aws_vpc.terraform
  ]
}

# Create route table in VPC
# route requires all key value pairs, contrary to documentation examples
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "terraformrtb" {
  vpc_id = aws_vpc.terraform.id
  route = [ {
    carrier_gateway_id = ""
    cidr_block = "0.0.0.0/0"
    destination_prefix_list_id = ""
    egress_only_gateway_id = ""
    gateway_id = aws_internet_gateway.terraformigw.id
    instance_id = ""
    ipv6_cidr_block = ""
    local_gateway_id = ""
    nat_gateway_id = ""
    network_interface_id = ""
    transit_gateway_id = ""
    vpc_endpoint_id = ""
    vpc_peering_connection_id = ""
  } ]

  tags = {
    "name" = "terraform"
  }
  depends_on = [
    aws_vpc.terraform,
    aws_internet_gateway.terraformigw
  ]
}

# Associate the route table to the webservers subnet
resource "aws_route_table_association" "webserverrtbassoc" {
  subnet_id = aws_subnet.webservers.id
  route_table_id = aws_route_table.terraformrtb.id

  depends_on = [
    aws_subnet.webservers,
    aws_route_table.terraformrtb
  ]
}

# Create a security group to secure access to only allowed ports for web traffic.

resource "aws_security_group" "webserverSecurity" {
  name        = "webserverSecurity"
  description = "Allow inbound traffic to web server"
  vpc_id = aws_vpc.terraform.id

  ingress {
    description      = "Allow TLS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Allow 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name = "terraform"
  }
  depends_on = [
    aws_vpc.terraform
  ]
}

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
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  security_groups = [aws_security_group.webserverSecurity.id]
  subnet_id = aws_subnet.webservers.id
  key_name = "N. Virginia"
  user_data = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install httpd
                  echo "<p> My Instance! </p>" >> /var/www/html/index.html
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF
  tags = {
    "name" = "terraform"
  }

  depends_on = [
    aws_security_group.webserverSecurity,
    aws_subnet.webservers
  ]
}

# Attach public IP to instance
resource "aws_eip" "webserverip" {
  vpc = true
  instance = aws_instance.webserver.id  
  depends_on = [
    aws_internet_gateway.terraformigw,
    aws_instance.webserver
  ]
}