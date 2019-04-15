#==============================================================
# Infrastructure Network / network.tf
#==============================================================

# Create the network resources that the rest of our infrastructure will be built in.

#--------------------------------------------------------------
# Network Core
#--------------------------------------------------------------

# Create the main VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.stack_name}-${var.environment}-vpc"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }

  lifecycle {
    ignore_changes  = "all"
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
    created_by  = "${var.user1}"
  }
  lifecycle {
    ignore_changes  = "all"
    prevent_destroy = true
  }
}

# Fetch subnet IDs for use by other resources
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = "${aws_vpc.vpc.id}"
}

#--------------------------------------------------------------
# Optional Outside Access to EC2 Instances
#--------------------------------------------------------------

# The below resources are needed to allow VPC external (inbound) traffic and can be
# deactivated if not needed.

# Attaching elastic IP to EC2 instance
resource "aws_eip" "ip-test-env" {
  instance = "${aws_instance.ubuntu_server.id}"
  vpc      = true
}

# Route traffic from internet to VPC
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.stack_name}-${var.environment}-gateway"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Setting up route table
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }

  tags {
    Name        = "${var.stack_name}-${var.environment}-route-table"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Associate route table to subnet
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${data.aws_subnet_ids.subnet_ids.ids[1]}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}
