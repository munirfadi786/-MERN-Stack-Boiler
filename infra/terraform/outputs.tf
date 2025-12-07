output "alb_dns" {
  value       = aws_lb.mern_alb.dns_name
  description = "DNS name of the load balancer"
}

output "asg_instance_ids" {
  value       = aws_autoscaling_group.mern_asg.*.id
  description = "List of instance IDs in ASG"
}
