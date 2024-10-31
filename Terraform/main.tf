provider "aws" {                        # Provider
  access_key = var.access_key        
  secret_key = var.secret_key          
  region     = var.region 
}


resource "aws_vpc" "wl5vpc" {         # VPC
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "wl5vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {     # Public Subnets in two Availability Zones
  vpc_id                  = aws_vpc.wl5vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "wl5sn - us-east-1a"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.wl5vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "wl5_pub_sn - us-east-1b"
  }
}


resource "aws_subnet" "private_subnet_1" {      # Private Subnets in two Availability Zones
  vpc_id            = aws_vpc.wl5vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "wl5_priv_sn - us-east-1a"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.wl5vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "wl5_priv_sn - us-east-1b"
  }
}

resource "aws_internet_gateway" "igw" {  # Internet Gateway
  vpc_id = aws_vpc.wl5vpc.id
  tags = {
    Name = "wl5_igw"
  }
}

resource "aws_eip" "eip" {               # Elastic IP
tags = {
    Name = "wl5_eip"
  }
depends_on = [ aws_internet_gateway.igw ]
}


resource "aws_nat_gateway" "nat_gw" {    # Nat Gateway
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "wl5_natgw"
  }
  depends_on = [aws_internet_gateway.igw]

}

resource "aws_route_table" "public_route_table" { # Public Route Table
  vpc_id = aws_vpc.wl5vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
#  route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = "local"
#   }
  tags = {
    Name = "wl5_pub_rt"
  }
}
resource "aws_route_table" "private_route_table" { # Private Route Table
  vpc_id = aws_vpc.wl5vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
#  route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = "local"
#   }
  tags = {
    Name = "wl5_priv_rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" { # Public Route Table Association
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "private_rt_assoc" { # Private Route Table Association
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id

}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_lb" "app_lb" {     # Application Load Balancer 
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "wl5_app_lb"
  }
}

resource "aws_security_group" "lb_sg" {     # ALB Security Group
  vpc_id = aws_vpc.wl5vpc.id
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "wl5_lb_sg"
  }
}

resource "aws_security_group" "frontend_sg" { # Frontend Security group
  vpc_id = aws_vpc.wl5vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
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
  tags = {
    "name"       : "wl5_front_sg"  
    "terraform"  : "true"
  }
}

resource "aws_security_group" "backend_sg" { # Backend security group
  description = "SSH & DJANGO"
  vpc_id = aws_vpc.wl5vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    "Name"      : "wl5_back_sg"                         
    "Terraform" : "true"                                
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
  
}
resource "aws_instance" "backend_server1" {    # Backend Server 1
  ami               = "ami-0866a3c8686eaeeba"                
                                        
  instance_type     = var.instance_type                 
  vpc_security_group_ids = [aws_security_group.backend_sg.id]    
  key_name          = "ecomnmerce_wl5"                
  tags = {
    "Name" : "backend1"         
  }
  subnet_id = aws_subnet.private_subnet_1.id
#   user_data = <<-EOF
#     #!/bin/bash

#     # Update and install required packages
#     sudo apt update -y
#     sudo apt install -y python3.9 python3.9-venv python3.9-dev git

#     # Clone the repository to the /home/ubuntu directory
#     git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

#     # Navigate to the backend project directory
#     cd /home/ubuntu/ecommerce_terraform_deployment/backend

#     # Set up Python virtual environment and activate it
#     python3.9 -m venv venv
#     source venv/bin/activate

#     # Install project dependencies
#     pip install -r requirements.txt

#     # Fetch the instance's private IP to configure Django settings
#     PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

#     # Modify ALLOWED_HOSTS in settings.py to allow access from the instance's private IP
#     sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$PRIVATE_IP']/" my_project/settings.py

#     # Apply Django migrations (to ensure database schema is up to date)
#     python manage.py migrate

#     # Start the Django development server
#     python manage.py runserver 0.0.0.0:8000 &
#  EOF
}

resource "aws_instance" "backend_server2" {    # Backend Server 2
  ami               = "ami-0866a3c8686eaeeba"                
                                        
  instance_type     = var.instance_type                 
  vpc_security_group_ids = [aws_security_group.backend_sg.id]    
  key_name          = "ecomnmerce_wl5"                
  tags = {
    "Name" : "backend2"         
  }
  subnet_id = aws_subnet.private_subnet_2.id
#   user_data = <<-EOF
#     #!/bin/bash

#     # Update and install required packages
#     sudo apt update -y
#     sudo apt install -y python3.9 python3.9-venv python3.9-dev git

#     # Clone the repository to the /home/ubuntu directory
#     git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

#     # Navigate to the backend project directory
#     cd /home/ubuntu/ecommerce_terraform_deployment/backend

#     # Set up Python virtual environment and activate it
#     python3.9 -m venv venv
#     source venv/bin/activate

#     # Install project dependencies
#     pip install -r requirements.txt

#     # Fetch the instance's private IP to configure Django settings
#     PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

#     # Modify ALLOWED_HOSTS in settings.py to allow access from the instance's private IP
#     sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$PRIVATE_IP']/" my_project/settings.py

#     # Apply Django migrations (to ensure database schema is up to date)
#     python manage.py migrate

#     # Start the Django development server
#     python manage.py runserver 0.0.0.0:8000 &
#  EOF
}

resource "aws_instance" "frontend_server1" {    # Frontend Server 1
  ami               = "ami-0866a3c8686eaeeba"                
                                        
  instance_type     = var.instance_type                 
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]    
  key_name          = "ecomnmerce_wl5"                
  tags = {
    "Name" : "frontend1"         
  }
  subnet_id = aws_subnet.public_subnet_1.id
#  user_data = <<-EOF
# #!/bin/bash

# # Fetch the backend private IP dynamically
# BACKEND_PRIVATE_IP="${aws_instance.backend_server1.private_ip}"
# FRONTEND_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
# ec2_key="${var.private_ec2_key}"
# jenkins_key="${var.jenkins_pub_key}"

# # Ensure .ssh directory exists
# mkdir -p ~/.ssh
# cd ~/.ssh

# # Append Jenkins SSH key to authorized_keys
# cat "$jenkins_key" >> authorized_keys

# # SSH into backend server
# ssh -i "$ec2_key" ubuntu@"$FRONTEND_PUBLIC_IP" << 'INNER_SSH'

# # Set up the backend
# sudo apt update -y
# sudo apt install -y python3.9 python3.9-venv python3.9-dev git

# # Clone the repository to /home/ubuntu directory
# git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

# # Backend setup
# cd /home/ubuntu/ecommerce_terraform_deployment/backend
# python3.9 -m venv venv
# source venv/bin/activate
# pip install -r requirements.txt

# # Configure Django settings
# PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
# sudo sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$PRIVATE_IP']/" my_project/settings.py

# # Apply Django migrations and start server in the background
# python manage.py migrate
# nohup python manage.py runserver 0.0.0.0:8000 &

# sleep 3

# exit
# INNER_SSH

# # Set up the frontend on the main server
# sudo apt update -y
# curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
# sudo apt install -y nodejs git

# # Clone the repository to /home/ubuntu
# git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

# sleep 3

# # Navigate to the frontend directory
# cd /home/ubuntu/ecommerce_terraform_deployment/frontend

# # Modify package.json to set the proxy field
# sudo sed -i "s|\"proxy\": \"\"|\"proxy\": \"http://$BACKEND_PRIVATE_IP:8000\"|" package.json

# # Install frontend dependencies and start application
# npm install
# export NODE_OPTIONS=--openssl-legacy-provider
# npm start
# EOF

}


resource "aws_instance" "frontend_server2" {    # Frontend Server 2
  ami               = "ami-0866a3c8686eaeeba"                
                                        
  instance_type     = var.instance_type                 
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]    
  key_name          = "ecomnmerce_wl5"                
  tags = {
    "Name" : "frontend2"         
  }
  subnet_id = aws_subnet.public_subnet_2.id
#   user_data = <<-EOF
# #!/bin/bash

# # Fetch the backend private IP dynamically
# BACKEND_PRIVATE_IP="${aws_instance.backend_server2.private_ip}"

# # Update and install Node.js and Git
# sudo apt update -y
# curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
# sudo apt install -y nodejs git

# # Clone the repository into the home directory
# git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

# sleep 3

# # Navigate to the frontend directory
# cd /home/ubuntu/ecommerce_terraform_deployment/frontend

# # Modify package.json to set the proxy field to the backend's private IP
# sed -i "s|\"proxy\": \"\"|\"proxy\": \"http://$BACKEND_PRIVATE_IP:8000\"|" package.json

# # Install dependencies
# npm install

# # Set Node.js options and start the frontend application
# export NODE_OPTIONS=--openssl-legacy-provider
# npm start
# EOF
}

resource "aws_db_instance" "postgres_db" {
  identifier           = "ecommerce-db"
  engine               = "postgres"
  engine_version       = "14.13"
  instance_class       = var.db_instance_class
  allocated_storage    = 20
  storage_type         = "standard"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "wl5_db"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "wl5_rds_sng"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.wl5vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wl5_rds_sg"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}