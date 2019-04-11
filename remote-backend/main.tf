#==============================================================
# main.tf
#==============================================================

provider "aws" {
  region  = "${var.region}"
  profile = "tng-play"
}

#--------------------------------------------------------------
# Remote State Infrastructure
#--------------------------------------------------------------

# Create the S3 bucket that terraform will use to store state

resource "aws_s3_bucket" "terraform_state" {
  bucket = "mstykow-tfstate"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name       = "terraform-state"
    owner      = "${var.owner}"
    stack_name = "${var.stack_name}"
    created_by = "terraform-dms"
  }
}