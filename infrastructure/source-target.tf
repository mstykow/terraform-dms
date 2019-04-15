#==============================================================
# Data Source and Target Instances / rds.tf
#==============================================================

#--------------------------------------------------------------
# Source
#--------------------------------------------------------------

# Create a source AWS RDS instance
resource "aws_db_instance" "source" {
  # Unique identifier among all DB instances owned by your AWS account in the current region
  identifier              = "${var.stack_name}-${var.environment}-${var.identifier}-source"
  allocated_storage       = "${var.source_storage}"
  engine                  = "${var.source_engine}"
  engine_version          = "${var.source_engine_version}"
  instance_class          = "${var.source_instance_class}"
  name                    = "${var.source_db_name}"
  port                    = "${var.source_db_port}"
  username                = "${var.source_username}"
  password                = "${var.source_password}"
  vpc_security_group_ids  = ["${aws_security_group.rds.id}"]
  multi_az                = "${var.source_rds_is_multi_az}"
  db_subnet_group_name    = "${aws_db_subnet_group.rds-subnet.id}"
  backup_retention_period = "${var.source_backup_retention_period}"
  backup_window           = "${var.source_backup_window}"
  maintenance_window      = "${var.source_maintenance_window}"
  storage_encrypted       = "${var.source_storage_encrypted}"
  storage_type            = "${var.source_storage_type}"
  skip_final_snapshot     = true
  parameter_group_name    = "${aws_db_parameter_group.dms.id}"

  tags {
    Name        = "${var.stack_name}_data_source"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Additional parameters needed for CDC process
resource "aws_db_parameter_group" "dms" {
  name        = "rds-pg"
  family      = "mysql5.6"
  description = "Parameter group for MySQL source for DMS"

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_checksum"
    value = "NONE"
  }
}

# Run the following SQL command on the MySQL database to make the binary logs available
# to AMS DMS:
# call mysql.rds_set_configuration('binlog retention hours', 24);

# Create a subnet group to house the RDS
resource "aws_db_subnet_group" "rds-subnet" {
  name        = "${var.stack_name}_${var.environment}_rds_subnet_group"
  description = "${var.stack_name} RDS Subnet Group"
  subnet_ids  = ["${data.aws_subnet_ids.subnet_ids.ids}"]

  tags {
    Name        = "${var.stack_name}_${var.environment}_rds_subnet_group"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

#--------------------------------------------------------------
# Target
#--------------------------------------------------------------

# Create a target S3 bucket
resource "aws_s3_bucket" "target_bucket" {
  bucket = "${var.target_bucket}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name       = "${var.stack_name}_data_target"
    owner      = "${var.owner}"
    stack_name = "${var.stack_name}"
    created_by = "${var.user1}"
  }
}
