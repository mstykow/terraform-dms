#==============================================================
# variables.tf
#==============================================================

# This file is used to set variables that are passed to sub
# modules to build our stack

#--------------------------------------------------------------
# Global Config
#--------------------------------------------------------------

# Variables used in the global config

variable "region" {
  default = "us-east-1"
}

variable "stack_name" {
  description = "The application stack name"
  default     = "ingest-test-stack"
}

variable "owner" {
  description = "A group email address to be used in tags"
  default     = "maxim.stykow@tngtech.com"
}

variable "creator" {
  description = "Backend creator"
  default     = "maxim"
}