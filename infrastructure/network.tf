#==============================================================
# network.tf
#==============================================================

# Create the network resource that the rest of our
# infrastructure will be built in.

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.stack_name}-${var.environment}-vpc"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "terraform-dms"
  }

  lifecycle {
    ignore_changes = "all"
    prevent_destroy = true
  }
}

# Create a subnet in each availability zone.

resource "aws_subnet" "subnet" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.vpc.id}"

  #vpc_id = "${var.vpc}"

  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, count.index + 1, 1)}"
  availability_zone = "${lookup(var.availability_zones, count.index)}"
  tags {
    Name        = "${var.stack_name}-${var.environment}-subnet-${lookup(var.availability_zones, count.index)}"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "terraform-dms"
  }
  lifecycle {
    ignore_changes = "all"
    #prevent_destroy = true
  }
}

# Fetch subnet IDs for use by other resources
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "${aws_vpc.vpc.id}"
}