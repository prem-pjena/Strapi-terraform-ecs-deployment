
# Strapi Terraform ECS Deployment

This project demonstrates the deployment of a Strapi application on AWS using Terraform, ECS (Elastic Container Service), and Fargate. It includes the setup of the necessary AWS resources and infrastructure, all defined in Infrastructure as Code (IaC) using Terraform.

## Overview

Strapi is an open-source headless CMS that provides a robust API backend. This project uses Terraform to provision the infrastructure and deploy Strapi on AWS ECS Fargate, making the deployment fully scalable and managed. It also leverages Terraform modules to keep the infrastructure code organized.

## Features

- **Strapi Application Deployment**: Deploy a Strapi application containerized with Docker on AWS ECS.
- **Infrastructure as Code (IaC)**: Terraform code to set up ECS, ECR, VPC, Load Balancers, and other necessary resources.
- **Scalability**: Using AWS Fargate for serverless container deployment.
- **CI/CD Pipeline**: Configured a **GitHub Actions** pipeline for continuous integration and deployment to automate testing, building, and deployment processes.

## Architecture

- **Amazon ECS (Fargate)**: For running Strapi in containers.
- **AWS Elastic Load Balancer (ELB)**: To distribute traffic evenly across the containers.
- **AWS ECR (Elastic Container Registry)**: To store the Strapi Docker image.
- **VPC (Virtual Private Cloud)**: To manage network configurations.
- **IAM Roles & Policies**: To manage access and security.

## Prerequisites

Before you begin, ensure you have the following installed:

- **AWS CLI**: Command-line tool to interact with AWS services.
- **Terraform**: To provision the infrastructure.
- **Docker**: For building and running the Strapi image.
- **Git**: For version control.

## Setup Guide

### 1. Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/prem-pjena/Strapi-terraform-ecs-deployment.git
cd Strapi-terraform-ecs-deployment
```

### 2. Configure AWS Credentials

Ensure that you have AWS CLI configured with the necessary access keys:

```bash
aws configure
```

### 3. Initialize Terraform

Run the following command to initialize Terraform and download the necessary providers:

```bash
terraform init
```

### 4. Configure Terraform Variables

Edit the `terraform.tfvars` file or set the variables through the command line to specify the necessary configurations, such as the AWS region, VPC configurations, and Strapi settings.

### 5. Apply Terraform Configuration

To create the infrastructure, run the following command:

```bash
terraform apply
```

### 6. Build and Push Docker Image

Build the Docker image for Strapi and push it to AWS ECR:

```bash
docker build -t strapi-app .
aws ecr create-repository --repository-name strapi-app --region us-east-1
docker tag strapi-app:latest <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/strapi-app:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
docker push <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/strapi-app:latest
```

### 7. Verify Deployment

After the `terraform apply` completes, navigate to your Load Balancer URL to verify that Strapi is running successfully.

### 8. CI/CD Pipeline

The project includes a CI/CD pipeline using **GitHub Actions** to automate the process of deploying new code changes. The workflow is configured to trigger on push to the `main` branch, including:

- **Testing**: Unit tests to ensure code quality.
- **Docker Build**: Build a Docker image for the Strapi application.
- **Deployment**: Automatically deploy to AWS ECS Fargate on successful changes.

The CI/CD pipeline ensures continuous integration and smooth deployment of any updates to the Strapi application.

## Cleanup

To destroy the deployed infrastructure and clean up AWS resources, run:

```bash
terraform destroy
```

## Contributing

Feel free to fork this repository and create a pull request for any improvements, bug fixes, or enhancements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
