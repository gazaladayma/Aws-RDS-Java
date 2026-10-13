# Existing public-facing Application Load Balancer security group.
resource "aws_security_group" "alb" {
  name        = "java-app-alb-sg"
  description = "Security group for Java application load balancer"
  vpc_id      = aws_vpc.java_app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Existing application EC2 security group.
resource "aws_security_group" "app" {
  name        = "java-app-ec2-sg"
  description = "Security group for Java application EC2 server"
  vpc_id      = aws_vpc.java_app.id

  # Application traffic from the ALB.
  ingress {
    description     = "java-app-alb-sg"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH access from the existing bastion security group.
  ingress {
    description     = "java-app-bastion-sg"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["sg-0d0303afe5fa6ad3c"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Existing RDS security group.
resource "aws_security_group" "db" {
  name        = "java-app-rds-sg"
  description = "Security group for RDS MySQL database"
  vpc_id      = aws_vpc.java_app.id

  # Only application instances can connect to MySQL.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Reuse the existing database subnet group across two Availability Zones.
resource "aws_db_subnet_group" "java_app" {
  name        = "java-app-rds-db-subnet-group"
  description = "Private DB subnet group for Java application RDS"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}
