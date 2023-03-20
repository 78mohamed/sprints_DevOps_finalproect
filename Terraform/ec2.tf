resource "aws_instance" "jenkins" {
  ami           = "ami-0c9978668f8d55984"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.aws-subnet.id
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile = aws_iam_instance_profile.ecr_access_profile.name
  key_name      = "aws-jenkins"
  tags = {
    Name = "jenkins"
  }
}



resource "aws_security_group" "main" {
  vpc_id      = aws_vpc.aws-vpc.id
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  },
  {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 8080
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 8080
  },
  {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 8096
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 8096
  }
  ]
}



resource "aws_iam_role" "ecr_access_role" {
  name = "ecr_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.ecr_access_role.name
}

resource "aws_iam_instance_profile" "ecr_access_profile" {
  name = "ecr_access_profile"

  role = aws_iam_role.ecr_access_role.name
}

