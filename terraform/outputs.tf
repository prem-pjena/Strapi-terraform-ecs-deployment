output "strapi_alb_url" {
  description = "URL of the Strapi application load balancer"
  value       = aws_lb.strapi-alb.dns_name
}
