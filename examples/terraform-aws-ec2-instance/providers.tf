terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.45"
    }
  }
}

provider "aws" {
  region = var.region

  ignore_tags {
    keys = [
      "domain_join",
      "fqdn",
      "nyl:appid",
    ]

    key_prefixes = [
      "nyl:platform:",
    ]
  }
}
