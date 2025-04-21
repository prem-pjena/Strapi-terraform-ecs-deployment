variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ecr_repo_uri" {
  description = "ECR repository URI for Strapi Docker image"
  default     = "815454675511.dkr.ecr.us-east-1.amazonaws.com/strapi-app"
}

variable "execution_role_arn" {
  description = "ARN of the ECS execution role"
  default     = "arn:aws:iam::815454675511:role/ecsTaskExecutionRole" # replace this later with actual ARN
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  default     = "arn:aws:iam::815454675511:role/ecsTaskRole" # replace this later with actual ARN
}
