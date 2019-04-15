#==============================================================
# DMS / dms.tf
#==============================================================

# DMS consists of three core components that must be created:
# 1. A replication instance
# 2. Endpoints
# 3. A replication task

#--------------------------------------------------------------
# Create Replication Instance
#--------------------------------------------------------------

# Create a new DMS replication instance
resource "aws_dms_replication_instance" "link" {
  allocated_storage            = "${var.replication_instance_storage}"
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  availability_zone            = "${lookup(var.availability_zones, count.index)}"
  engine_version               = "${var.replication_instance_engine_version}"
  multi_az                     = false
  preferred_maintenance_window = "${var.replication_instance_maintenance_window}"
  publicly_accessible          = true
  replication_instance_class   = "${var.replication_instance_class}"
  replication_instance_id      = "dms-replication-instance-tf-ingest-test"
  replication_subnet_group_id  = "${aws_dms_replication_subnet_group.dms.id}"
  vpc_security_group_ids       = ["${aws_security_group.rds.id}"]

  tags {
    Name        = "${var.stack_name}-dms-${var.environment}-${lookup(var.availability_zones, count.index)}"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Create a subnet group using existing VPC subnets
resource "aws_dms_replication_subnet_group" "dms" {
  replication_subnet_group_description = "DMS replication subnet group"
  replication_subnet_group_id          = "dms-replication-subnet-group-tf"
  subnet_ids                           = ["${data.aws_subnet_ids.subnet_ids.ids}"]
}

#--------------------------------------------------------------
# Create Endpoints
#--------------------------------------------------------------

# Endpoint information when using MySQL as a source:
# https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.MySQL.html

# Create an endpoint for the source database
resource "aws_dms_endpoint" "source" {
  #certificate_arn = "" # SSL certificate if desired
  database_name = "${var.source_db_name}"
  endpoint_id   = "${var.stack_name}-dms-${var.environment}-source"
  endpoint_type = "source"
  engine_name   = "${var.source_engine_name}"
  username      = "${var.source_app_username}"
  password      = "${var.source_app_password}"
  port          = "${var.source_db_port}"
  server_name   = "${aws_db_instance.source.address}"
  ssl_mode      = "${var.source_ssl_mode}"

  #extra_connection_attributes = ""

  tags {
    Name        = "${var.stack_name}-dms-${var.environment}-source"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Create an endpoint for the target database
resource "aws_dms_endpoint" "target" {
  database_name               = "${var.target_db_name}"
  endpoint_id                 = "${var.stack_name}-dms-${var.environment}-target"
  endpoint_type               = "target"
  engine_name                 = "${var.target_engine_name}"
  extra_connection_attributes = "dataFormat=parquet; parquetVersion=PARQUET_2_0;"

  s3_settings {
    service_access_role_arn = "${aws_iam_role.dmsvpcrole.arn}"
    bucket_name             = "${var.target_bucket}"
    bucket_folder           = "${var.target_bucket_folder}"
    compression_type        = "${var.compression_type}"
  }

  tags {
    Name        = "${var.stack_name}-dms-${var.environment}-target"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

#--------------------------------------------------------------
# Create Replication Task
#--------------------------------------------------------------

# Create a new DMS replication task
resource "aws_dms_replication_task" "dblink" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = "${aws_dms_replication_instance.link.replication_instance_arn}"
  replication_task_id       = "${var.replication_task_id}"
  source_endpoint_arn       = "${aws_dms_endpoint.source.endpoint_arn}"
  target_endpoint_arn       = "${aws_dms_endpoint.target.endpoint_arn}"
  table_mappings            = "${data.template_file.table_mappings.rendered}"
  replication_task_settings = "${data.template_file.dblink-settings.rendered}"

  tags {
    Name        = "${var.stack_name}-dms-${var.environment}-replication-task"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Reference the table mappings
data "template_file" "table_mappings" {
  template = "${file("table_mappings.json")}"
}

# Reference the replication task settings
data "template_file" "dblink-settings" {
  template = "${file("task_settings.json")}"
}
