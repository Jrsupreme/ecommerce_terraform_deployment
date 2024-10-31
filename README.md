# Workload 5 Documentation

## Overview

This workload, "Workload 5," deploys a secure and highly available e-commerce application infrastructure on AWS using Terraform for Infrastructure as Code (IaC). The setup includes a Virtual Private Cloud (VPC), subnet architecture, security configurations, and application components (frontend and backend) with load balancing. The purpose is to automate provisioning of cloud infrastructure necessary to support scalable and fault-tolerant web applications.

## Key Components

1. **Provider Configuration**
    - Specifies AWS as the provider, requiring `access_key`, `secret_key`, and `region` as variables.
2. **Virtual Private Cloud (VPC)**
    - Creates a new VPC (`wl5vpc`) with CIDR block `10.0.0.0/16`, DNS support, and hostnames enabled.
    - Peering is established with the default VPC for inter-VPC communication.
3. **Subnets and Routing**
    - **Public Subnets**: Created in two Availability Zones (AZs), `us-east-1a` and `us-east-1b`.
    - **Private Subnets**: For backend components in `us-east-1a` and `us-east-1b`.
    - **Route Tables**:
        - Public route table routes traffic to the internet via the Internet Gateway.
        - Private route table routes internet traffic through a NAT Gateway in a public subnet.
4. **Internet Gateway and NAT Gateway**
    - **Internet Gateway**: Enables outbound internet access for resources in the public subnets.
    - **NAT Gateway**: Allows instances in private subnets to access the internet securely.
5. **Load Balancer**
    - An Application Load Balancer (ALB) is configured to distribute traffic across frontend instances, ensuring high availability.
6. **Security Groups**
    - **ALB Security Group**: Allows traffic on port 3000 from any IP.
    - **Frontend Security Group**: Permits HTTP (port 80), application (port 3000), and SSH access (port 22).
    - **Backend Security Group**: Restricts access to HTTP (port 80), Django application (port 8000), and SSH access (port 22).
    - **RDS Security Group**: Allows PostgreSQL access (port 5432) from backend servers only.
7. **EC2 Instances**
    - **Frontend Servers**: Two public EC2 instances in different AZs, hosting the frontend (React) of the application.
    - **Backend Servers**: Two private EC2 instances for running Django, configured with the backend security group and peered with the RDS instance.
8. **Database (RDS)**
    - PostgreSQL RDS instance with allocated storage, deployed within private subnets and accessible only by the backend servers.

## Dependencies

- **AWS Credentials**: Ensure AWS credentials (access key and secret key) are securely provided.
- **Terraform**: Version compatible with AWS provider is required.
- **Public Key**: A pre-configured SSH key (`ecommerce_wl5`) for secure access to EC2 instances.

## Outputs

- `rds_endpoint`: Exports the RDS instance endpoint, which is essential for database connection configurations in the application backend.

## Usage

1. Configure necessary variables in a `terraform.tfvars` file.
2. Run `terraform init` to initialize the configuration.
3. Use `terraform plan` to preview changes.
4. Apply changes with `terraform apply` to deploy resources.

This setup provides a resilient, scalable infrastructure, supporting dynamic application demands with secure access control and load distribution across multiple instances and availability zones.

OpenAI. (2024). ChatGPT (Month Day version) [Large language model]. https://chat.openai.com
