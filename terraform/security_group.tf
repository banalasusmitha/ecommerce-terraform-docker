# ---------------------------------------------------------------
# Security group = firewall for the EC2 instance
# ---------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Allow HTTP to frontend, SSH, and internal traffic between services"
  vpc_id      = aws_vpc.main.id

  # Frontend: anyone on the internet can open the website on port 80
  ingress {
    description = "HTTP to frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend services (3001-3004): only reachable from inside the VPC
  ingress {
    description = "Internal communication between services"
    from_port   = 3001
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # SSH so we can log in and check the containers
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # Outbound: allow everything (needed to download Docker and pull images)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}
