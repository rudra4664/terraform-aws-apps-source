resource "aws_network_interface" "primary" {
  subnet_id          = var.primary_network_interface.subnet_id
  description        = var.primary_network_interface.description
  security_groups    = var.primary_network_interface.security_group_ids
  private_ip         = var.primary_network_interface.private_ip
  private_ips        = var.primary_network_interface.private_ips
  private_ips_count  = var.primary_network_interface.private_ips_count
  source_dest_check  = var.primary_network_interface.source_dest_check
  interface_type     = var.primary_network_interface.interface_type
  ipv4_prefixes      = var.primary_network_interface.ipv4_prefixes
  ipv4_prefix_count  = var.primary_network_interface.ipv4_prefix_count
  ipv6_addresses     = var.primary_network_interface.ipv6_addresses
  ipv6_address_count = var.primary_network_interface.ipv6_address_count
  ipv6_prefixes      = var.primary_network_interface.ipv6_prefixes
  ipv6_prefix_count  = var.primary_network_interface.ipv6_prefix_count

  tags = merge(
    {
      Name = var.instance.name
    },
    var.tags,
    var.primary_network_interface.tags
  )
}

resource "aws_network_interface" "additional" {
  for_each = var.additional_network_interfaces

  subnet_id          = each.value.subnet_id
  description        = each.value.description
  security_groups    = each.value.security_group_ids
  private_ip         = each.value.private_ip
  private_ips        = each.value.private_ips
  private_ips_count  = each.value.private_ips_count
  source_dest_check  = each.value.source_dest_check
  interface_type     = each.value.interface_type
  ipv4_prefixes      = each.value.ipv4_prefixes
  ipv4_prefix_count  = each.value.ipv4_prefix_count
  ipv6_addresses     = each.value.ipv6_addresses
  ipv6_address_count = each.value.ipv6_address_count
  ipv6_prefixes      = each.value.ipv6_prefixes
  ipv6_prefix_count  = each.value.ipv6_prefix_count

  tags = merge(
    {
      Name = "${var.instance.name}-${each.key}"
    },
    var.tags,
    each.value.tags
  )
}

resource "aws_network_interface_attachment" "additional" {
  for_each = aws_network_interface.additional

  instance_id          = aws_instance.current.id
  network_interface_id = each.value.id
  device_index         = var.additional_network_interfaces[each.key].device_index
}
