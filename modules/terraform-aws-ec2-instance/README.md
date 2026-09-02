
# Terraform AWS EC2 Module

## Overview

This Terraform module provisions an Amazon EC2 instance following NYL enterprise standards and best practices.

The module provides a reusable and standardized way to deploy EC2 instances with support for:

- Standard NYL account-owned AMI lookup
- NYL Strategic AMI lookup
- Explicit AMI override
- Primary Elastic Network Interface (ENI)
- Additional ENIs
- Root EBS customization
- Additional EBS volumes
- Customer-managed KMS encryption
- CloudWatch EC2 Auto Recovery
- IMDSv2 enforcement
- Enterprise tagging

---

# Features

- Deploy a single EC2 instance
- Create and attach a dedicated primary ENI
- Create and attach multiple additional ENIs
- Create and attach multiple EBS volumes
- Support customer-managed KMS encryption
- Automatic AWS Systems Manager (SSM) instance profile for Strategic AMIs
- Optional CloudWatch EC2 Auto Recovery alarm
- IMDSv2 enabled by default
- CPU Options support
- Burstable Instance Credit Specification
- Enterprise input validations
- Enterprise tagging support

---

# Architecture

```
Application Repository
        │
        ▼
terraform-aws-ec2
        │
        ├── EC2 Instance
        ├── Primary ENI
        ├── Additional ENIs
        ├── Root EBS Volume
        ├── Additional EBS Volumes
        └── CloudWatch Recovery Alarm
```

---

# AMI Selection

The module supports three different methods for selecting an AMI.

## 1. Explicit AMI

Specify the AMI ID directly.

```hcl
instance = {
  ami = "ami-xxxxxxxxxxxxxxxxx"
}
```

This has the highest priority.

---

## 2. Standard NYL AMI

Provide the following values:

- lob
- env
- os_type

The module automatically searches the current AWS account using the following tag:

```
tag:Name = <lob>-<env>-<os_type>
```

Example:

```
claims-dev-amzlinux2
```

---

## 3. Strategic AMI

Provide:

```hcl
instance = {
  use_strategic_ami   = true
  strategic_os_type   = "NYL Amazon Linux 2023"
  strategic_ami_build = "PROD"
}
```

The module searches the NYL Image Builder accounts and automatically selects the most recent matching AMI.

---

# AMI Selection Priority

```
Explicit AMI
      │
      ▼
Strategic AMI
      │
      ▼
Standard NYL AMI
```

---

# Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5 |
| AWS Provider | >= 5.0 |

---

# Required Inputs

| Name | Description |
|------|-------------|
| lob | Line of Business |
| env | Environment |
| instance | EC2 instance configuration |
| primary_network_interface | Primary ENI configuration |

---

# Optional Inputs

| Name | Description |
|------|-------------|
| additional_network_interfaces | Additional ENIs |
| additional_volumes | Additional EBS volumes |
| cloudwatch_alarm | CloudWatch Auto Recovery configuration |
| tags | Common resource tags |
| volume_tags | Additional EBS volume tags |

---

# Example Usage

```hcl
module "ec2" {

  source = "../terraform-aws-ec2"

  lob = "claims"

  env = "dev"

  instance = {

    name = "claims-app"

    instance_type = "t3.large"

    os_type = "amzlinux2"

    key_name = "enterprise-key"

    root_block_device = {

      volume_size = 100

      encrypted = true

      kms_key_id = module.kms.kms_key_arn

    }

  }

  primary_network_interface = {

    subnet_id = "subnet-xxxxxxxx"

    security_group_ids = [

      "sg-xxxxxxxx"

    ]

  }

  tags = {

    Application = "Claims"

    Environment = "Dev"

    Owner = "Platform Team"

  }

}
```

---

# Strategic AMI Example

```hcl
module "ec2" {

  source = "../terraform-aws-ec2"

  lob = "claims"

  env = "prod"

  instance = {

    name = "claims-prod"

    instance_type = "m6i.large"

    key_name = "enterprise-key"

    use_strategic_ami = true

    strategic_os_type = "NYL Amazon Linux 2023"

    strategic_ami_build = "PROD"

  }

  primary_network_interface = {

    subnet_id = "subnet-xxxxxxxx"

    security_group_ids = [

      "sg-xxxxxxxx"

    ]

  }

}
```

---

# Outputs

| Output | Description |
|---------|-------------|
| instance_id | EC2 Instance ID |
| instance_arn | EC2 Instance ARN |
| instance_private_ip | EC2 private IP |
| instance_private_dns | EC2 private DNS |
| primary_network_interface_id | Primary ENI ID |
| additional_network_interface_ids | Additional ENI IDs |
| additional_volume_ids | Additional EBS Volume IDs |
| cloudwatch_alarm_arn | CloudWatch Auto Recovery Alarm ARN |

---

# CloudWatch Auto Recovery

The module can optionally create a CloudWatch alarm that automatically recovers an EC2 instance when the AWS system status check fails.

Enable it using:

```hcl
cloudwatch_alarm = {
  create = true
}
```

---

# Customer Managed KMS

The module supports customer-managed KMS keys.

Example:

```hcl
root_block_device = {

  encrypted = true

  kms_key_id = module.kms.kms_key_arn

}
```

Additional EBS volumes also support customer-managed KMS keys.

---

# Enterprise Standards

This module follows NYL enterprise standards by providing:

- Standard NYL AMI lookup
- Strategic Image Builder AMI lookup
- Customer-managed KMS support
- IMDSv2 enforcement
- Enterprise tagging
- CloudWatch Auto Recovery
- Multi-ENI support
- Multi-EBS support
- Enterprise input validation
- Automatic SSM instance profile for Strategic AMIs

---

# Notes

- A dedicated primary ENI is always created.
- Additional ENIs are optional.
- Additional EBS volumes are optional.
- Root and additional EBS volumes support customer-managed KMS keys.
- AMI changes are ignored after deployment to prevent unintended instance replacement.
- IMDSv2 is enabled by default.
- Strategic AMIs automatically use the AWS Systems Manager default instance profile if no custom instance profile is provided.
- The module supports explicit AMI IDs, standard NYL AMIs, and Strategic AMIs.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.15.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.45.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_instance.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_volume_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.strategic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_network_interfaces"></a> [additional\_network\_interfaces](#input\_additional\_network\_interfaces) | Additional network interface configurations. | <pre>map(object({<br/>    subnet_id          = string<br/>    device_index       = number<br/>    description        = optional(string)<br/>    security_group_ids = set(string)<br/>    private_ip         = optional(string)<br/>    private_ips        = optional(set(string), [])<br/>    private_ips_count  = optional(number)<br/>    source_dest_check  = optional(bool, true)<br/>    interface_type     = optional(string)<br/>    ipv4_prefixes      = optional(list(string))<br/>    ipv4_prefix_count  = optional(number)<br/>    ipv6_addresses     = optional(list(string))<br/>    ipv6_address_count = optional(number)<br/>    ipv6_prefixes      = optional(list(string))<br/>    ipv6_prefix_count  = optional(number)<br/>    tags               = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_additional_volumes"></a> [additional\_volumes](#input\_additional\_volumes) | Additional EBS volume configurations. | <pre>map(object({<br/>    device_name                    = string<br/>    size                           = optional(number)<br/>    type                           = optional(string, "gp3")<br/>    snapshot_id                    = optional(string)<br/>    kms_key_id                     = optional(string)<br/>    iops                           = optional(number)<br/>    throughput                     = optional(number)<br/>    force_detach                   = optional(bool, false)<br/>    multi_attach_enabled           = optional(bool, false)<br/>    final_snapshot                 = optional(bool, false)<br/>    skip_destroy                   = optional(bool, false)<br/>    stop_instance_before_detaching = optional(bool, false)<br/>    tags                           = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment. | `string` | n/a | yes |
| <a name="input_instance"></a> [instance](#input\_instance) | EC2 Instance configuration. | <pre>object({<br/>    name                = string<br/>    ami                 = optional(string)<br/>    instance_type       = string<br/>    use_strategic_ami   = optional(bool, false)<br/>    os_type             = optional(string)<br/>    strategic_os_type   = optional(string)<br/>    strategic_ami_build = optional(string)<br/><br/>    key_name = string<br/><br/>    iam_instance_profile = optional(string)<br/><br/>    monitoring    = optional(bool, true)<br/>    ebs_optimized = optional(bool, false)<br/><br/>    disable_api_termination              = optional(bool, false)<br/>    disable_api_stop                     = optional(bool, false)<br/>    instance_initiated_shutdown_behavior = optional(string, "stop")<br/><br/>    hibernation       = optional(bool, false)<br/>    get_password_data = optional(bool, false)<br/><br/>    placement_group = optional(string)<br/>    tenancy         = optional(string, "default")<br/>    host_id         = optional(string)<br/><br/>    user_data                   = optional(string)<br/>    user_data_base64            = optional(string)<br/>    user_data_replace_on_change = optional(bool, false)<br/><br/>    volume_tags = optional(map(string), {})<br/><br/>    metadata_options = optional(object({<br/>      http_endpoint               = optional(string, "enabled")<br/>      http_put_response_hop_limit = optional(number, 1)<br/>      instance_metadata_tags      = optional(string, "enabled")<br/>    }), {})<br/><br/>    cpu_options = optional(object({<br/>      core_count       = number<br/>      threads_per_core = number<br/>      amd_sev_snp      = optional(string)<br/>    }))<br/><br/>    credit_specification = optional(object({<br/>      cpu_credits = string<br/>    }))<br/><br/>    root_block_device = optional(object({<br/>      volume_size           = number<br/>      volume_type           = optional(string, "gp3")<br/>      iops                  = optional(number)<br/>      throughput            = optional(number)<br/>      encrypted             = optional(bool, true)<br/>      kms_key_id            = optional(string)<br/>      delete_on_termination = optional(bool, true)<br/>      tags                  = optional(map(string))<br/>    }))<br/><br/>    ephemeral_block_device = optional(list(object({<br/>      device_name  = string<br/>      virtual_name = optional(string)<br/>      no_device    = optional(bool)<br/>    })), [])<br/><br/>    capacity_reservation_specification = optional(object({<br/>      capacity_reservation_preference = optional(string, "open")<br/>      capacity_reservation_target = optional(object({<br/>        capacity_reservation_id                 = optional(string)<br/>        capacity_reservation_resource_group_arn = optional(string)<br/>      }))<br/>    }))<br/><br/>    launch_template = optional(object({<br/>      id      = optional(string)<br/>      name    = optional(string)<br/>      version = optional(string, "$Default")<br/>    }))<br/><br/>    instance_market_options = optional(object({<br/>      market_type = optional(string, "spot")<br/>      spot_options = optional(object({<br/>        instance_interruption_behavior = optional(string, "terminate")<br/>        max_price                      = optional(string)<br/>        spot_instance_type             = optional(string, "one-time")<br/>        valid_until                    = optional(string)<br/>      }))<br/>    }))<br/><br/>    enclave_options = optional(object({<br/>      enabled = optional(bool, false)<br/>    }))<br/><br/>    maintenance_options = optional(object({<br/>      auto_recovery = optional(string, "default")<br/>    }))<br/><br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_lob"></a> [lob](#input\_lob) | Line of Business identifier used to locate the correct self-owned AMI via its Name tag (<lob>-<env>-<os\_type>). | `string` | n/a | yes |
| <a name="input_primary_network_interface"></a> [primary\_network\_interface](#input\_primary\_network\_interface) | Primary network interface configuration. | <pre>object({<br/>    subnet_id          = string<br/>    description        = optional(string)<br/>    security_group_ids = set(string)<br/>    private_ip         = optional(string)<br/>    private_ips        = optional(set(string), [])<br/>    private_ips_count  = optional(number)<br/>    source_dest_check  = optional(bool, true)<br/>    interface_type     = optional(string)<br/>    ipv4_prefixes      = optional(list(string))<br/>    ipv4_prefix_count  = optional(number)<br/>    ipv6_addresses     = optional(list(string))<br/>    ipv6_address_count = optional(number)<br/>    ipv6_prefixes      = optional(list(string))<br/>    ipv6_prefix_count  = optional(number)<br/>    tags               = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags applied to all supported resources. | `map(string)` | `{}` | no |
| <a name="input_volume_tags"></a> [volume\_tags](#input\_volume\_tags) | Additional tags applied to EBS volumes. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password_data"></a> [password\_data](#output\_password\_data) | Base-64 encoded encrypted Windows administrator password. Populated only when instance.get\_password\_data is true; decrypt locally with the private key paired with instance.key\_name. |
| <a name="output_resources"></a> [resources](#output\_resources) | Map of all resources created by this module. |
<!-- END_TF_DOCS -->
