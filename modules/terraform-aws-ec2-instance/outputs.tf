output "resources" {
  description = "Map of all resources created by this module."

  value = {
    instance                                 = aws_instance.current
    primary_network_interface                = aws_network_interface.primary
    additional_network_interfaces            = aws_network_interface.additional
    additional_network_interface_attachments = aws_network_interface_attachment.additional
    additional_volumes                       = aws_ebs_volume.additional
    additional_volume_attachments            = aws_volume_attachment.additional
  }
}

output "password_data" {
  description = "Base-64 encoded encrypted Windows administrator password. Populated only when instance.get_password_data is true; decrypt locally with the private key paired with instance.key_name."

  value     = aws_instance.current.password_data
  sensitive = true
}
