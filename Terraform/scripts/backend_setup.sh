#!/bin/bash
# Set up the backend
sudo apt update -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install -y python3.9 python3.9-venv python3.9-dev git

# Clone the repository to /home/ubuntu directory
git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

# Backend setup
cd /home/ubuntu/ecommerce_terraform_deployment/backend
python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure Django settings
#PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
#sudo sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$PRIVATE_IP']/" my_project/settings.py

# Apply Django migrations and start server in the background
python manage.py makemigration
python manage.py migrate
nohup python manage.py runserver 0.0.0.0:8000 &