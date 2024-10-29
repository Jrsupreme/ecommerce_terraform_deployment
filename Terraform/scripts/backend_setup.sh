#!/bin/bash
# Update and install required packages
sudo apt update -y
sudo apt install -y python3.9 python3.9-venv python3.9-dev git

# Clone the repository
git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git 

# Navigate to project directory
cd /home/ubuntu/ecommerce_terraform_deployment/backend

# Set up Python virtual environment and install dependencies
python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Modify ALLOWED_HOSTS in settings.py to allow access from the backend's private IP
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$PRIVATE_IP']/" /home/ubuntu/ecommerce_terraform_deployment/backend/my_project/settings.py

# Start the Django server
python manage.py runserver 0.0.0.0:8000