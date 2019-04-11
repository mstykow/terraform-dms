#==============================================================
# variables.tf
#==============================================================

# This file is used to set variables that are passed to sub
# modules to build our stack

#--------------------------------------------------------------
# Terraform Remote State
#--------------------------------------------------------------

# Define the remote objects that terraform will use to store
# state. We use a remote store, so that you can run destroy
# from a seperate machine to the one it was built on.

terraform {
  required_version = "~> 0.10"

  backend "s3" {
    encrypt = true
    bucket  = "mstykow-tfstate"
    key     = "ingest/terraform.tfstate"
    region  = "us-east-1"
    profile = "tng-play"
  }
}

#--------------------------------------------------------------
# Global Config
#--------------------------------------------------------------

# Variables used in the global config

provider "aws" {
  region  = "${var.region}"
  profile = "tng-play"
}

variable "availability_zones" {
  description = "Geographically distanced areas inside the region"
  type        = "map"

  default = {
    "0" = "us-east-1a"
    "1" = "us-east-1b"
    "2" = "us-east-1c"
  }
}

#--------------------------------------------------------------
# Meta Data
#--------------------------------------------------------------

# Used in tagging and naming the resources

variable "region" {
  default = "us-east-1"
}

variable "stack_name" {
  description = "The name of our application"
  default     = "ingest-test-stack"
}

variable "owner" {
  description = "A group email address to be used in tags"
  default     = "maxim.stykow@tngtech.com"
}

variable "environment" {
  description = "Used for seperating terraform backends and naming items"
  default     = "dev"
}

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "vpc" {
  description = "already existing VPC ID"
  default     = "vpc-0196f23e45dc1f73c"
}
