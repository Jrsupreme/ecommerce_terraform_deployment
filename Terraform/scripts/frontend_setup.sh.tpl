#!/bin/bash
# Update and install Node.js
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs git

# Clone the repository
git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git 

sleep 3

# Navigate to the frontend directory
cd /home/ubuntu/ecommerce_terraform_deployment/frontend

 # Modify package.json to set the proxy field to the backend's private IP
BACKEND_PRIVATE_IP="http://BACKEND_PRIVATE_IP:8000"
sed -i "s|\"proxy\": \"\"|\"proxy\": \"$BACKEND_PRIVATE_IP\"|" package.json

# Install dependencies
npm install

# Set Node.js options and start the frontend application
export NODE_OPTIONS=--openssl-legacy-provider
npm start