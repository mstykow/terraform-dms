#==============================================================
# EC2 Application Server / ec2-server.tf
#==============================================================

#--------------------------------------------------------------
# Build Application Server
#--------------------------------------------------------------

# Select machine image (AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Load application server with AMI, key pair, security group
resource "aws_instance" "ubuntu_server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${data.aws_subnet_ids.subnet_ids.ids[1]}"

  #key_name      = "${aws_key_pair.generated_key.key_name}" # option 1)
  #key_name      = "${aws_key_pair.public_key.key_name}" # option 2)
  key_name = "${var.key_name}" # option 3)

  vpc_security_group_ids = ["${aws_security_group.rds.id}", "${aws_security_group.public.id}"]

  tags = {
    Name        = "ubuntu-server"
    owner       = "${var.owner}"
    stack_name  = "${var.stack_name}"
    environment = "${var.environment}"
    created_by  = "${var.user1}"
  }
}

#--------------------------------------------------------------
# EC2 SSH Key Options
#--------------------------------------------------------------


/*
# 1a) Generate key on the fly
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
*/


/*
# 1b) Create key pair from generated key with key_name
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.tls_key.public_key_openssh}"
}
*/


/*
# 2) Create key pair from variable key_public with key_name
resource "aws_key_pair" "public_key" {
  key_name   = "${var.key_name}"
  public_key = "${var.key_public}"
}
*/


# 3) Use an exisiting key pair referenced by name in variable `key_name`

