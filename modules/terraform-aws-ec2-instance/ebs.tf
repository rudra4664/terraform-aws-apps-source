resource "aws_ebs_volume" "additional" {
  for_each = var.additional_volumes

  availability_zone    = aws_instance.current.availability_zone
  size                 = each.value.size
  type                 = each.value.type
  snapshot_id          = each.value.snapshot_id
  encrypted            = true
  kms_key_id           = each.value.kms_key_id
  iops                 = each.value.iops
  throughput           = each.value.throughput
  multi_attach_enabled = each.value.multi_attach_enabled
  final_snapshot       = each.value.final_snapshot

  tags = merge(
    {
      Name = "${var.instance.name}-${each.key}"
    },
    var.volume_tags,
    each.value.tags
  )
}

resource "aws_volume_attachment" "additional" {
  for_each = aws_ebs_volume.additional

  device_name                    = var.additional_volumes[each.key].device_name
  volume_id                      = each.value.id
  instance_id                    = aws_instance.current.id
  force_detach                   = var.additional_volumes[each.key].force_detach
  skip_destroy                   = var.additional_volumes[each.key].skip_destroy
  stop_instance_before_detaching = var.additional_volumes[each.key].stop_instance_before_detaching
}
