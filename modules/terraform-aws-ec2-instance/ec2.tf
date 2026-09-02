resource "aws_instance" "current" {
  ami                                  = local.selected_ami
  instance_type                        = var.instance.instance_type
  key_name                             = var.instance.key_name
  monitoring                           = var.instance.monitoring
  ebs_optimized                        = var.instance.ebs_optimized
  disable_api_termination              = var.instance.disable_api_termination
  disable_api_stop                     = var.instance.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance.instance_initiated_shutdown_behavior
  hibernation                          = var.instance.hibernation
  get_password_data                    = var.instance.get_password_data
  placement_group                      = var.instance.placement_group
  tenancy                              = var.instance.tenancy
  host_id                              = var.instance.host_id
  user_data                            = var.instance.user_data
  user_data_base64                     = var.instance.user_data_base64
  user_data_replace_on_change          = var.instance.user_data_replace_on_change
  volume_tags                          = var.instance.volume_tags

  iam_instance_profile = (
    (
      var.instance.iam_instance_profile != null &&
      var.instance.iam_instance_profile != ""
    )
    ? var.instance.iam_instance_profile
    : (
      var.instance.use_strategic_ami
      ? "AWSSystemsManagerDefaultEC2InstanceManagementRole"
      : null
    )
  )

  primary_network_interface {
    network_interface_id = aws_network_interface.primary.id
  }

  dynamic "root_block_device" {
    for_each = (
      var.instance.root_block_device == null
      ? []
      : [var.instance.root_block_device]
    )

    content {
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
      encrypted             = root_block_device.value.encrypted
      kms_key_id            = root_block_device.value.kms_key_id
      delete_on_termination = root_block_device.value.delete_on_termination
      tags                  = root_block_device.value.tags
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.instance.ephemeral_block_device

    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = ephemeral_block_device.value.virtual_name
      no_device    = ephemeral_block_device.value.no_device
    }
  }

  metadata_options {
    http_endpoint               = var.instance.metadata_options.http_endpoint
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = var.instance.metadata_options.instance_metadata_tags
  }

  dynamic "cpu_options" {
    for_each = (
      var.instance.cpu_options == null
      ? []
      : [var.instance.cpu_options]
    )

    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
      amd_sev_snp      = cpu_options.value.amd_sev_snp
    }
  }

  dynamic "credit_specification" {
    for_each = (
      var.instance.credit_specification == null
      ? []
      : [var.instance.credit_specification]
    )

    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = (
      var.instance.capacity_reservation_specification == null
      ? []
      : [var.instance.capacity_reservation_specification]
    )

    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = (
          capacity_reservation_specification.value.capacity_reservation_target == null
          ? []
          : [capacity_reservation_specification.value.capacity_reservation_target]
        )

        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  dynamic "launch_template" {
    for_each = (
      var.instance.launch_template == null
      ? []
      : [var.instance.launch_template]
    )

    content {
      id      = launch_template.value.id
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }

  dynamic "instance_market_options" {
    for_each = (
      var.instance.instance_market_options == null
      ? []
      : [var.instance.instance_market_options]
    )

    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = (
          instance_market_options.value.spot_options == null
          ? []
          : [instance_market_options.value.spot_options]
        )

        content {
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  dynamic "enclave_options" {
    for_each = (
      var.instance.enclave_options == null
      ? []
      : [var.instance.enclave_options]
    )

    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "maintenance_options" {
    for_each = (
      var.instance.maintenance_options == null
      ? []
      : [var.instance.maintenance_options]
    )

    content {
      auto_recovery = maintenance_options.value.auto_recovery
    }
  }

  dynamic "timeouts" {
    for_each = (
      var.instance.timeouts == null
      ? []
      : [var.instance.timeouts]
    )

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  tags = merge(
    {
      Name = var.instance.name
    },
    var.tags
  )
}

data "aws_ami" "account" {
  count = (
    !var.instance.use_strategic_ami &&
    var.instance.ami == null
  ) ? 1 : 0

  most_recent = true
  owners      = ["self"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "tag:Name"
    values = [
      "${var.lob}-${var.env}-${var.instance.os_type}",
    ]
  }
}

data "aws_ami" "strategic" {
  count = (
    var.instance.use_strategic_ami &&
    var.instance.ami == null
  ) ? 1 : 0

  most_recent = true
  owners      = local.strategic_ami_owner_accts

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = [
      "${var.instance.strategic_os_type}*",
    ]
  }

  filter {
    name = "description"
    values = [
      "*built in the '${upper(var.instance.strategic_ami_build)}' Environment*",
    ]
  }
}
