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
      echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > ./../ansible/aws-jenkins.pem
      chmod 400 ./../ansible/aws-jenkins.pem
    EOT
  }
}








variable "vpc_block" {
  description = "The CIDR range for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet01_block" {
  description = "CidrBlock for subnet 01 within the VPC"
  type        = string
  default     = "192.168.64.0/18"
}

variable "subnet02_block" {
  description = "CidrBlock for subnet 02 within the VPC"
  type        = string
  default     = "192.168.128.0/18"
}

variable "subnet03_block" {
  description = "CidrBlock for subnet 03 within the VPC. This is used only if the region has more than 2 AZs."
  type        = string
  default     = "192.168.192.0/18"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MY-EKS-VPC"
  }
}

resource "aws_internet_gateway" "eks_igw" {
   vpc_id = aws_vpc.eks_vpc.id
}



resource "aws_route_table" "eks_public_routetable" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name    = "Public Subnets"
    Network = "Public"
  }
}

resource "aws_route" "eks_internet_gateway_route" {
  route_table_id         = aws_route_table.eks_public_routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

resource "aws_subnet" "eks_subnet01" {
  cidr_block        = var.subnet01_block
  vpc_id            = aws_vpc.eks_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "EKS-Subnet01"
  }
}

resource "aws_subnet" "eks_subnet02" {
  cidr_block        = var.subnet02_block
  vpc_id            = aws_vpc.eks_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "EKS-Subnet02"
  }
}

resource "aws_subnet" "eks_subnet03" {
  cidr_block        = var.subnet03_block
  vpc_id            = aws_vpc.eks_vpc.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[2]
  


  tags = {
    Name = "EKS-Subnet03"
  }
}

resource "aws_route_table_association" "eks_subnet01_association" {
  subnet_id      = aws_subnet.eks_subnet01.id
  route_table_id = aws_route_table.eks_public_routetable.id
}

resource "aws_route_table_association" "eks_subnet02_association" {
  subnet_id      = aws_subnet.eks_subnet02.id
  route_table_id = aws_route_table.eks_public_routetable.id
}

resource "aws_route_table_association" "eks_subnet03_association" {
  subnet_id      = aws_subnet.eks_subnet03.id
  route_table_id = aws_route_table.eks_public_routetable.id
}

resource "aws_security_group" "eks_control_plane_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "ControlPlaneSecurityGroup"
  }
}

resource "aws_security_group" "eks_node_group_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ControlPlaneSecurityGroup"
  }
}


output "subnet_ids" {
  description = "All subnets in the VPC"
  value       = join(",", [aws_subnet.eks_subnet01.id, aws_subnet.eks_subnet02.id, aws_subnet.eks_subnet03.id])
}

output "security_groups" {
  description = "Security group for the cluster control plane communication with worker nodes"
  value       = aws_security_group.eks_control_plane_sg.id
}

output "vpc_id" {
  description = "The VPC Id"
  value       = aws_vpc.eks_vpc.id
}

data "aws_availability_zones" "available" {
  state = "available"
}





