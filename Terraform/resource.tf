resource "aws_vpc" "aws-vpc" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
#    enable_dns_support = "true"
#    enable_dns_hostnames = "true"
    tags = {
        Name = "mydefault-vpc"
    }
}
resource "aws_internet_gateway" "vpc-internet-gateway" {
    vpc_id = aws_vpc.aws-vpc.id
}


resource "aws_subnet" "aws-subnet" {
    vpc_id = aws_vpc.aws-vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "subnet-private-1"
    }
}



resource "aws_route_table" "route-table" {
    vpc_id = aws_vpc.aws-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc-internet-gateway.id
    }
    tags = {
        Name = "route-table"
    }
}
resource "aws_route_table_association" "route-table-association" {
    subnet_id      = aws_subnet.aws-subnet.id
    route_table_id = aws_route_table.route-table.id
}


resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  # Name of key : Write custom name of your key
  key_name   = "aws-jenkins"

  # Public Key : The public will be generated using the refernce of tls_private_key.terrafrom_generated_private_key
  public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh

  # Store private key :  Generate and save private key(aws_keys_pairs.pem) in currect directory
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > aws-jenkins.pem
      chmod 400 aws-jenkins.pem
    EOT
  }
}
