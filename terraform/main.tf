provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "strapi-vpc"
  }
}

# Subnets
resource "aws_subnet" "subnet_a" {
  vpc_id              = aws_vpc.main.id
  cidr_block          = "10.0.1.0/24"
  availability_zone   = "us-east-1a"
  tags = {
    Name = "strapi-subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id              = aws_vpc.main.id
  cidr_block          = "10.0.2.0/24"
  availability_zone   = "us-east-1b"
  tags = {
    Name = "strapi-subnet-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "strapi-gw"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "strapi-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.main.id
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi-cluster" {
  name = "strapi-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi-task" {
  family                   = "strapi-task"
  execution_role_arn       = "arn:aws:iam::815454675511:role/ecsTaskExecutionRole"   # Ensure role exists and has permissions
  task_role_arn            = "arn:aws:iam::815454675511:role/ecsTaskRole"  # Ensure this role exists and is correctly configured
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  
  container_definitions = jsonencode([{
    name      = "strapi-app"
    image     = "815454675511.dkr.ecr.us-east-1.amazonaws.com/strapi-app:latest"
    essential = true
    portMappings = [
      {
        containerPort = 1337
        hostPort      = 1337
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "DATABASE_HOST"
        value = "your-database-host"
      },
      {
        name  = "DATABASE_PORT"
        value = "5432"
      }
    ]
    healthCheck = {
      command    = ["CMD", "curl", "-f", "http://localhost:1337"]
      interval   = 30
      timeout    = 5
      retries    = 3
      startPeriod = 10
    }
  }])
}

# ECS Service (Fargate)
resource "aws_ecs_service" "strapi-service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi-cluster.id
  task_definition = aws_ecs_task_definition.strapi-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    security_groups = [aws_security_group.strapi-sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi-tg.arn
    container_name   = "strapi-app"
    container_port   = 1337
  }
}

# Security Group
resource "aws_security_group" "strapi-sg" {
  name        = "strapi-sg"
  description = "Allow inbound traffic on ports 1337 and 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # This allows traffic from anywhere. For restricted access, specify a specific IP range.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "strapi-alb" {
  name               = "strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.strapi-sg.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  enable_deletion_protection     = false
  enable_cross_zone_load_balancing = true
}

# ALB Target Group (Use IP Target Type for Fargate)
resource "aws_lb_target_group" "strapi-tg" {
  name          = "strapi-tg"
  port          = 1337
  protocol      = "HTTP"
  vpc_id        = aws_vpc.main.id
  target_type   = "ip"  # Fargate tasks require the target type to be 'ip'
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.strapi-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.strapi-tg.arn
    type             = "forward"
  }
}
