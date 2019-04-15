#==============================================================
# Security Groups / security.tf
#==============================================================

# Security groups for the EC2 instances
resource "aws_security_group" "public" {
  name        = "${var.stack_name}_${var.environment}_public_sg"
  description = "Allow SSH inbound traffic for public test instances"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.stack_name}-${var.environment}-public-sg"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

# Security groups for the RDS
resource "aws_security_group" "rds" {
  name        = "${var.stack_name}_${var.environment}_rds_sg"
  description = "Allow no inbound traffic"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port = "${var.source_db_port}"
    to_port   = "${var.source_db_port}"
    protocol  = "TCP"
    self      = true
  }

  /*
  ingress {
    from_port = "${var.target_db_port}"
    to_port   = "${var.target_db_port}"
    protocol  = "TCP"
    self      = true
  }
  */

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name        = "${var.stack_name}-${var.environment}-rds-sg"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}
