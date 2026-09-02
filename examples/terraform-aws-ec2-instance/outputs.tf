output "instance_id" {
  description = "ID of the created EC2 instance."
  value       = module.ec2.resources.instance.id
}

output "instance_private_ip" {
  description = "Primary private IP address of the created EC2 instance."
  value       = module.ec2.resources.primary_network_interface.private_ip
}

output "additional_volume_ids" {
  description = "IDs of the additional EBS volumes attached to the instance."
  value       = { for k, v in module.ec2.resources.additional_volumes : k => v.id }
}
