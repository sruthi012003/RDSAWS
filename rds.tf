provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "existing_vpc" {
  id = "vpc-0d1f96d135591e82d"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = data.aws_vpc.existing_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-1b"
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow RDS access"
  vpc_id      = data.aws_vpc.existing_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

resource "aws_db_instance" "example_rds" {
  identifier              = "example-rds"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = "exampledb"
  username                = "admin"
  password                = "YourSecurePassword123!"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
}
