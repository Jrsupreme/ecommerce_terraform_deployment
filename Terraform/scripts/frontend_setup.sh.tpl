# Set up the frontend on the main server
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs git

# Clone the repository to /home/ubuntu
git clone https://github.com/Jrsupreme/ecommerce_terraform_deployment.git /home/ubuntu/ecommerce_terraform_deployment

sleep 3

# Navigate to the frontend directory
cd /home/ubuntu/ecommerce_terraform_deployment/frontend

# Modify package.json to set the proxy field
sudo sed -i "s|\"proxy\": \"\"|\"proxy\": \"http://$BACKEND_PRIVATE_IP:8000\"|" package.json

# Install frontend dependencies and start application
npm install

export NODE_OPTIONS=--openssl-legacy-provider
npm start