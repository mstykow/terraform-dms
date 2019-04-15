#==============================================================
# Global Variables / variables.tf
#==============================================================

# This file is used to set variables that are passed to sub
# modules to build our stack.

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
  description = "VPC region"
}

variable "stack_name" {
  description = "The application stack name"
}

variable "owner" {
  description = "A group email address to be used in tags"
}

variable "user1" {
  description = "Name of engineer 1"
  default     = "user1"
}

variable "user2" {
  description = "Name of engineer 2"
  default     = "user2"
}

variable "environment" {
  description = "Used for seperating terraform backends and naming items: dev | prod"
  default     = "dev"
}

variable "identifier" {
  description = "Name suffix of resources defined in rds.tf"
}

/*
variable "key_public" {
  description = "Explicit key to attach to EC2 instances"
}
*/

variable "key_name" {
  description = "Key pair name on AWS to attach to EC2 instances"
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
}

#--------------------------------------------------------------
# DMS Replication Config
#--------------------------------------------------------------

variable "replication_instance_maintenance_window" {
  description = "Maintenance window in UTC for the replication instance"
  default     = "sun:10:30-sun:14:30"
}

variable "replication_instance_storage" {
  description = "Size of the replication instance in GB"
  default     = "5"
}

variable "replication_instance_engine_version" {
  description = "Engine version of the replication instance"
  default     = "3.1.3"
}

variable "replication_instance_class" {
  description = "Instance class of replication instance"
  default     = "dms.t2.micro"
}

variable "replication_task_id" {
  description = "Unique identifier/name for the task"
  default     = "ingest-test-task1"
}

#--------------------------------------------------------------
# DMS Target Config
#--------------------------------------------------------------

variable "target_bucket" {
  description = "Name of the target S3 bucket"
  default     = "ingest-test-targetbucket"
}

variable "target_bucket_folder" {
  description = "Name of the target folder in target S3 bucket"
  default     = "mysqlTest"
}

variable "target_db_name" {
  description = "Name of the target database"
  default     = "ingest_test_targetdb"
}

# Can be one of aurora | azuredb | docdb | dynamodb | mariadb | mongodb | mysql | oracle | postgres | redshift | s3 | sqlserver | sybase
variable "target_engine_name" {
  description = "Engine type, example values mysql, postgres"
  default     = "s3"
}

variable "compression_type" {
  description = "Compress files in S3? Options are NONE | GZIP."
  default     = "NONE"
}

#--------------------------------------------------------------
# DMS Source Config
#--------------------------------------------------------------

variable "source_app_username" {
  description = "Username for the endpoint to access the source database"
  default     = "testuser"
}

variable "source_app_password" {
  description = "Password for the endpoint to access the source database"
  default     = "testuserpw"
}

variable "source_username" {
  description = "Username to access the source database"
  default     = "testuser"
}

variable "source_password" {
  description = "Password of the source database"
  default     = "testuserpw"
}

# Must be non-zero for CDC to work
variable "source_backup_retention_period" {
  description = "The days to retain RDS backups for (0-35)"
  default     = "10"
}

variable "source_backup_window" {
  description = "RDS backup window in UTC"
  default     = "14:00-17:00"
}

variable "source_rds_is_multi_az" {
  description = "Create backup database in separate availability zone"
  default     = "false"
}

variable "source_maintenance_window" {
  description = "RDS maintenance window in UTC"
  default     = "Mon:00:00-Mon:03:00"
}

variable "source_db_name" {
  description = "name of the target database"
  default     = "ingest_test_sourcedb"
}

variable "source_db_port" {
  description = "The port the application server will access the database on"
  default     = 5432
}

# Can be one of aurora | aurora-mysql | aurora-postgresql | mariadb | mysql | oracle-ee | oracle-se2 | oracle-se1 | oracle-se | postgres | sqlserver-ee | sqlserver-se | sqlserver-ex | sqlserver-web
variable "source_engine" {
  description = "The string of the database engine to be used for this instance"
  default     = "mysql"
}

# Can be one of aurora | azuredb | docdb | dynamodb | mariadb | mongodb | mysql | oracle | postgres | redshift | s3 | sqlserver | sybase
variable "source_engine_name" {
  description = "Engine name for DMS endpoint"
  default     = "mysql"
}

variable "source_engine_version" {
  description = "Engine version (look up availability in AWS reference)"
  default     = "5.6.40"
}

variable "source_instance_class" {
  description = "Instance class"
  default     = "db.t2.micro"
}

variable "source_storage" {
  description = "Storage size in GB"
  default     = "20"                 # 20 is free tier
}

variable "source_storage_type" {
  description = "storage type: standard | gp2 | io1"
  default     = "standard"
}

variable "source_storage_encrypted" {
  description = "Encrypt storage?"
  default     = false
}

# Can be one of none | require | verify-ca | verify-full
# See https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.SSL.html
# for which is supported for your DB engine
variable "source_ssl_mode" {
  description = "Type of SSL to use if desired"
  default     = "none"
}
