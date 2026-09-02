module "ec2" {
  source                        = "app.terraform.io/NYL-Prod/apps-source/aws//modules/terraform-aws-ec2-instance"
  lob                           = var.lob
  env                           = var.env
  instance                      = var.ec2.instance
  primary_network_interface     = var.ec2.primary_network_interface
  additional_volumes            = var.ec2.additional_volumes
  additional_network_interfaces = var.ec2.additional_network_interfaces
  tags                          = var.ec2.tags
}
