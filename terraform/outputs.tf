output "strapi_alb_url" {
  description = "URL of the Strapi application load balancer"
  value       = aws_lb.strapi_lb.dns_name
}
