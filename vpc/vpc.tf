# Create a VPC for this project
resource "aws_vpc" "terraform" {
    cidr_block = "172.16.0.0/16"

    tags = {
      "name" = "terraform"
    }
}

# Create a subnet for our server(s)
# reference to the terraform VPC
# must be created after the VPC, use depends_on to force proper order
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
# reference to the terraform VPC
# must be created after the VPC, use depends_on to force proper order
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
# reference to VPC and Internet Gateway, use depends_on to force proper order
# primary purpose of this RTB is to enable public IP access on the webserver
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
# reference to subnet and route table
# use depends_on to ensure proper order
resource "aws_route_table_association" "webserverrtbassoc" {
  subnet_id = aws_subnet.webservers.id
  route_table_id = aws_route_table.terraformrtb.id

  depends_on = [
    aws_subnet.webservers,
    aws_route_table.terraformrtb
  ]
}

# Create a security group to secure access to only allowed ports for web traffic.
# User Variables.tf to insert private IP to restrict management of the web server

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
  ingress {
    description      = "Allow 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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
# Send output to be used in other modules
output "tf_sg_id" {
    value = "${aws_security_group.webserverSecurity.id}"  
}
output "tf_subnet_id"{
    value = "${aws_subnet.webservers.id}"
}