# --- Public load balancer: the ONLY public entry point to the website
#     itself (the app server has no public IP at all). ---
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Public ALB - only public entry point to the app"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anyone"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

# --- Bastion: the ONLY SSH entry point. The app server accepts SSH from
#     this security group alone, never from the internet directly. ---
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Bastion - jump host for reaching the private app server over SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH (restrict via ssh_ingress_cidr / SSH_INGRESS_CIDR repo variable)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-bastion-sg" }
}

# --- App server: no direct internet exposure at all. HTTP only from the
#     ALB, SSH only from the bastion. ---
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Private app server (Nginx + Tomcat) - reachable only via ALB (HTTP) and bastion (SSH)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from the load balancer only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from the bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-app-sg" }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "MySQL/RDS - only reachable from the app tier, never the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app servers only"
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

  tags = { Name = "${var.project_name}-db-sg" }
}
