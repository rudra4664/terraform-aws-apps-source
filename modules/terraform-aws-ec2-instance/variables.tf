variable "instance" {
  description = "EC2 Instance configuration."

  type = object({
    name                = string
    ami                 = optional(string)
    instance_type       = string
    use_strategic_ami   = optional(bool, false)
    os_type             = optional(string)
    strategic_os_type   = optional(string)
    strategic_ami_build = optional(string)

    key_name = optional(string)

    iam_instance_profile = optional(string)

    monitoring    = optional(bool, true)
    ebs_optimized = optional(bool, false)

    disable_api_termination              = optional(bool, false)
    disable_api_stop                     = optional(bool, false)
    instance_initiated_shutdown_behavior = optional(string, "stop")

    hibernation       = optional(bool, false)
    get_password_data = optional(bool, false)

    placement_group = optional(string)
    tenancy         = optional(string, "default")
    host_id         = optional(string)

    user_data                   = optional(string)
    user_data_base64            = optional(string)
    user_data_replace_on_change = optional(bool, false)

    volume_tags = optional(map(string), {})

    metadata_options = optional(object({
      http_endpoint          = optional(string, "enabled")
      instance_metadata_tags = optional(string, "enabled")
    }), {})

    cpu_options = optional(object({
      core_count       = number
      threads_per_core = number
      amd_sev_snp      = optional(string)
    }))

    credit_specification = optional(object({
      cpu_credits = string
    }))

    root_block_device = optional(object({
      volume_size           = number
      volume_type           = optional(string, "gp3")
      iops                  = optional(number)
      throughput            = optional(number)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
      delete_on_termination = optional(bool, true)
      tags                  = optional(map(string))
    }))

    ephemeral_block_device = optional(list(object({
      device_name  = string
      virtual_name = optional(string)
      no_device    = optional(bool)
    })), [])

    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string, "open")
      capacity_reservation_target = optional(object({
        capacity_reservation_id                 = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      }))
    }))

    launch_template = optional(object({
      id      = optional(string)
      name    = optional(string)
      version = optional(string, "$Default")
    }))

    instance_market_options = optional(object({
      market_type = optional(string, "spot")
      spot_options = optional(object({
        instance_interruption_behavior = optional(string, "terminate")
        max_price                      = optional(string)
        spot_instance_type             = optional(string, "one-time")
        valid_until                    = optional(string)
      }))
    }))

    enclave_options = optional(object({
      enabled = optional(bool, false)
    }))

    maintenance_options = optional(object({
      auto_recovery = optional(string, "default")
    }))

    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = (
      length(trimspace(var.instance.name)) > 0
    )

    error_message = "Instance name must not be empty."
  }

  validation {
    condition = contains(
      [
        "dedicated",
        "default",
        "host",
      ],
      var.instance.tenancy
    )

    error_message = "Instance tenancy must be one of default, dedicated or host."
  }

  validation {
    condition = contains(
      [
        "stop",
        "terminate",
      ],
      var.instance.instance_initiated_shutdown_behavior
    )

    error_message = "Shutdown behavior must be either stop or terminate."
  }

  validation {
    condition = (
      var.instance.metadata_options.http_endpoint == "enabled" ||
      var.instance.metadata_options.http_endpoint == "disabled"
    )

    error_message = "Metadata endpoint must be enabled or disabled."
  }

  validation {
    condition = (
      var.instance.root_block_device == null ||
      contains(
        [
          "gp2",
          "gp3",
          "io1",
          "io2",
          "sc1",
          "st1",
          "standard",
        ],
        var.instance.root_block_device.volume_type
      )
    )

    error_message = "Invalid root EBS volume type."
  }

  validation {
    condition = (
      var.instance.root_block_device == null ||
      var.instance.root_block_device.volume_size > 0
    )

    error_message = "Root volume size must be greater than zero."
  }

  validation {
    condition = (
      var.instance.cpu_options == null ||
      (
        var.instance.cpu_options.core_count > 0 &&
        var.instance.cpu_options.threads_per_core > 0
      )
    )

    error_message = "CPU options must contain valid core count and threads per core."
  }

  validation {
    condition = (
      var.instance.cpu_options == null ||
      var.instance.cpu_options.amd_sev_snp == null ||
      contains(
        [
          "enabled",
          "disabled",
        ],
        var.instance.cpu_options.amd_sev_snp
      )
    )

    error_message = "cpu_options.amd_sev_snp must be either enabled or disabled."
  }

  validation {
    condition = (
      !var.instance.hibernation ||
      (
        var.instance.root_block_device != null &&
        var.instance.root_block_device.encrypted
      )
    )

    error_message = "Hibernation requires an encrypted root_block_device."
  }

  validation {
    condition = contains(
      [
        "open",
        "none",
      ],
      var.instance.capacity_reservation_specification == null
      ? "open"
      : var.instance.capacity_reservation_specification.capacity_reservation_preference
    )

    error_message = "capacity_reservation_specification.capacity_reservation_preference must be either open or none."
  }

  validation {
    condition = (
      var.instance.launch_template == null ||
      (
        (var.instance.launch_template.id != null ? 1 : 0) +
        (var.instance.launch_template.name != null ? 1 : 0)
      ) == 1
    )

    error_message = "launch_template requires exactly one of id or name."
  }

  validation {
    condition = (
      var.instance.instance_market_options == null ||
      contains(
        [
          "spot",
          "capacity-block",
          "interruptible-capacity-reservation",
        ],
        var.instance.instance_market_options.market_type
      )
    )

    error_message = "instance_market_options.market_type must be one of spot, capacity-block or interruptible-capacity-reservation."
  }

  validation {
    condition = (
      var.instance.instance_market_options == null ||
      var.instance.instance_market_options.spot_options == null ||
      contains(
        [
          "hibernate",
          "stop",
          "terminate",
        ],
        var.instance.instance_market_options.spot_options.instance_interruption_behavior
      )
    )

    error_message = "instance_market_options.spot_options.instance_interruption_behavior must be one of hibernate, stop or terminate."
  }

  validation {
    condition = (
      var.instance.instance_market_options == null ||
      var.instance.instance_market_options.spot_options == null ||
      contains(
        [
          "one-time",
          "persistent",
        ],
        var.instance.instance_market_options.spot_options.spot_instance_type
      )
    )

    error_message = "instance_market_options.spot_options.spot_instance_type must be either one-time or persistent."
  }

  validation {
    condition = (
      var.instance.maintenance_options == null ||
      contains(
        [
          "default",
          "disabled",
        ],
        var.instance.maintenance_options.auto_recovery
      )
    )

    error_message = "maintenance_options.auto_recovery must be either default or disabled."
  }

  validation {
    condition = (
      var.instance.credit_specification == null ||
      contains(
        [
          "standard",
          "unlimited",
        ],
        var.instance.credit_specification.cpu_credits
      )
    )

    error_message = "CPU credits must be either standard or unlimited."
  }

  validation {
    condition = !(
      var.instance.user_data != null &&
      var.instance.user_data_base64 != null
    )

    error_message = "Specify either user_data or user_data_base64, not both."
  }

  validation {
    condition = (
      (
        var.instance.ami != null &&
        trimspace(var.instance.ami) != ""
      ) ||
      var.instance.use_strategic_ami ||
      (
        var.instance.os_type != null &&
        trimspace(var.instance.os_type) != ""
      )
    )

    error_message = "Specify either ami, or os_type, or enable use_strategic_ami."
  }

  validation {
    condition = (
      !var.instance.use_strategic_ami ||
      (
        var.instance.strategic_os_type != null &&
        trimspace(var.instance.strategic_os_type) != "" &&
        var.instance.strategic_ami_build != null &&
        trimspace(var.instance.strategic_ami_build) != ""
      )
    )

    error_message = "strategic_os_type and strategic_ami_build are required when use_strategic_ami is true."
  }

  validation {
    condition = (
      var.instance.os_type == null ||
      contains(
        [
          "amzlinux1",
          "amzlinux2",
          "eks",
          "rhel7",
          "win2016",
          "win2019",
          "win2019-core",
        ],
        var.instance.os_type
      )
    )

    error_message = "os_type must be one of: amzlinux1, amzlinux2, eks, rhel7, win2016, win2019 or win2019-core."
  }

  validation {
    condition = (
      var.instance.strategic_os_type == null ||
      contains(
        [
          "NYL Amazon Linux 2 Kernel",
          "NYL Amazon Linux 2023",
          "NYL Microsoft Windows Server 2016-v",
          "NYL Microsoft Windows Server 2019",
          "NYL Microsoft Windows Server 2019 core",
          "NYL Microsoft Windows Server 2022",
        ],
        var.instance.strategic_os_type
      )
    )

    error_message = "Invalid strategic_os_type."
  }

  validation {
    condition = (
      var.instance.strategic_ami_build == null ||
      contains(
        [
          "DEV",
          "PROD",
          "QA",
          "STAGE",
          "TEST",
        ],
        upper(var.instance.strategic_ami_build)
      )
    )

    error_message = "strategic_ami_build must be one of TEST, DEV, QA, STAGE or PROD."
  }
}

variable "primary_network_interface" {
  description = "Primary network interface configuration."

  type = object({
    subnet_id          = string
    description        = optional(string)
    security_group_ids = set(string)
    private_ip         = optional(string)
    private_ips        = optional(set(string), [])
    private_ips_count  = optional(number)
    source_dest_check  = optional(bool, true)
    interface_type     = optional(string)
    ipv4_prefixes      = optional(list(string))
    ipv4_prefix_count  = optional(number)
    ipv6_addresses     = optional(list(string))
    ipv6_address_count = optional(number)
    ipv6_prefixes      = optional(list(string))
    ipv6_prefix_count  = optional(number)
    tags               = optional(map(string), {})
  })

  validation {
    condition = (
      length(trimspace(var.primary_network_interface.subnet_id)) > 0
    )

    error_message = "Subnet ID must not be empty."
  }

  validation {
    condition = (
      var.primary_network_interface.interface_type == null ||
      var.primary_network_interface.interface_type == "efa"
    )

    error_message = "interface_type must be efa when specified."
  }

  validation {
    condition = (
      var.primary_network_interface.private_ip == null ||
      can(cidrhost("${var.primary_network_interface.private_ip}/32", 0))
    )

    error_message = "Primary private IP must be a valid IPv4 address."
  }

  validation {
    condition = alltrue([
      for ip in var.primary_network_interface.private_ips :
      can(cidrhost("${ip}/32", 0))
    ])

    error_message = "All secondary private IP addresses must be valid IPv4 addresses."
  }

  validation {
    condition = (
      var.primary_network_interface.private_ip == null ||
      !contains(
        var.primary_network_interface.private_ips,
        var.primary_network_interface.private_ip
      )
    )

    error_message = "Primary private IP must not be included in private_ips."
  }

  validation {
    condition = (
      length(var.primary_network_interface.security_group_ids) > 0
    )

    error_message = "At least one security group must be specified for the primary network interface."
  }
}

variable "additional_network_interfaces" {
  description = "Additional network interface configurations."

  type = map(object({
    subnet_id          = string
    device_index       = number
    description        = optional(string)
    security_group_ids = set(string)
    private_ip         = optional(string)
    private_ips        = optional(set(string), [])
    private_ips_count  = optional(number)
    source_dest_check  = optional(bool, true)
    interface_type     = optional(string)
    ipv4_prefixes      = optional(list(string))
    ipv4_prefix_count  = optional(number)
    ipv6_addresses     = optional(list(string))
    ipv6_address_count = optional(number)
    ipv6_prefixes      = optional(list(string))
    ipv6_prefix_count  = optional(number)
    tags               = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      eni.interface_type == null || eni.interface_type == "efa"
    ])

    error_message = "interface_type must be efa when specified for additional network interfaces."
  }

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      length(trimspace(eni.subnet_id)) > 0
    ])

    error_message = "Subnet ID must not be empty for additional network interfaces."
  }

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      eni.device_index > 0
    ])

    error_message = "Device index for additional network interfaces must be greater than zero."
  }

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      length(eni.security_group_ids) > 0
    ])

    error_message = "At least one security group must be specified for each additional network interface."
  }

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      eni.private_ip == null ||
      can(cidrhost("${eni.private_ip}/32", 0))
    ])

    error_message = "Primary private IP must be a valid IPv4 address."
  }

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      alltrue([
        for ip in eni.private_ips :
        can(cidrhost("${ip}/32", 0))
      ])
    ])

    error_message = "All secondary private IP addresses must be valid IPv4 addresses."
  }

  validation {
    condition = alltrue([
      for eni in values(var.additional_network_interfaces) :
      eni.private_ip == null ||
      !contains(eni.private_ips, eni.private_ip)
    ])

    error_message = "Primary private IP must not be included in private_ips."
  }
}

variable "additional_volumes" {
  description = "Additional EBS volume configurations."

  type = map(object({
    device_name                    = string
    size                           = optional(number)
    type                           = optional(string, "gp3")
    snapshot_id                    = optional(string)
    kms_key_id                     = optional(string)
    iops                           = optional(number)
    throughput                     = optional(number)
    force_detach                   = optional(bool, false)
    multi_attach_enabled           = optional(bool, false)
    final_snapshot                 = optional(bool, false)
    skip_destroy                   = optional(bool, false)
    stop_instance_before_detaching = optional(bool, false)
    tags                           = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      !volume.multi_attach_enabled ||
      contains(
        [
          "io1",
          "io2",
        ],
        volume.type
      )
    ])

    error_message = "multi_attach_enabled is supported only for io1 and io2 volumes."
  }

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      length(trimspace(volume.device_name)) > 0
    ])

    error_message = "Device name must not be empty for additional volumes."
  }

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      (
        volume.snapshot_id != null ||
        (
          volume.size != null &&
          volume.size > 0
        )
      )
    ])

    error_message = "Volume size must be specified when snapshot_id is not provided."
  }

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      contains(
        [
          "gp2",
          "gp3",
          "io1",
          "io2",
          "sc1",
          "st1",
          "standard",
        ],
        volume.type
      )
    ])

    error_message = "Invalid EBS volume type."
  }

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      (
        volume.throughput == null ||
        volume.type == "gp3"
      )
    ])

    error_message = "Throughput is supported only for gp3 volumes."
  }

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      (
        volume.iops == null ||
        contains(
          [
            "gp3",
            "io1",
            "io2",
          ],
          volume.type
        )
      )
    ])

    error_message = "IOPS is supported only for gp3, io1 and io2 volumes."
  }

  validation {
    condition = alltrue([
      for volume in values(var.additional_volumes) :
      (
        volume.snapshot_id == null ||
        volume.size == null ||
        volume.size > 0
      )
    ])

    error_message = "Volume size must be greater than zero when specified."
  }
}

variable "lob" {
  description = "Line of Business identifier used to locate the correct self-owned AMI via its Name tag (<lob>-<env>-<os_type>)."

  type = string

  validation {
    condition     = length(trimspace(var.lob)) > 0
    error_message = "lob must not be empty."
  }
}

variable "env" {
  description = "Environment."

  type = string

  validation {
    condition = contains(
      [
        "dev",
        "prod",
        "qa",
        "stage",
        "test",
      ],
      lower(var.env)
    )

    error_message = "env must be one of: dev, qa, stage, prod or test."
  }
}

variable "tags" {
  description = "Common tags applied to all supported resources."

  type = map(string)

  default = {}

  validation {
    condition = alltrue([
      for key, value in var.tags :
      (
        length(trimspace(key)) > 0 &&
        length(trimspace(value)) > 0
      )
    ])

    error_message = "Tag keys and values must not be empty."
  }
}

variable "volume_tags" {
  description = "Additional tags applied to EBS volumes."

  type = map(string)

  default = {}

  validation {
    condition = alltrue([
      for key, value in var.volume_tags :
      (
        length(trimspace(key)) > 0 &&
        length(trimspace(value)) > 0
      )
    ])

    error_message = "Volume tag keys and values must not be empty."
  }
}
