variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "lob" {
  description = "Account Name."
  type        = string
}

variable "env" {
  description = "Environment (dev, qa, stage, prod or test)."
  type        = string
}

variable "ec2" {
  description = "EC2 module configuration."

  type = object({
    instance = object({
      name          = string
      instance_type = optional(string, "t3.large")
      os_type       = optional(string)
      ami           = optional(string)
      key_name      = optional(string)

      root_block_device = object({
        volume_size = optional(number, 100)
        encrypted   = optional(bool, true)
        kms_key_id  = optional(string)
      })
    })

    primary_network_interface = object({
      subnet_id          = string
      security_group_ids = set(string)
    })

    additional_volumes = optional(map(object({
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
    })), {})

    additional_network_interfaces = optional(map(object({
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
    })), {})

    tags = optional(map(string), {})
  })

  default = {
    instance = {
      name          = "ec2-test-01"
      instance_type = "t3.large"
      os_type       = "amzlinux2"

      root_block_device = {
        volume_size = 100
        encrypted   = true
      }
    }

    primary_network_interface = {
      subnet_id          = "subnet-xxxxxxxx"
      security_group_ids = ["sg-xxxxxxxx"]
    }

    additional_volumes            = {}
    additional_network_interfaces = {}

    tags = {
      Environment = "dev"
    }
  }
}
