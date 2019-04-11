# Select machine image
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

# Load server with AMI
resource "aws_instance" "ubuntu_server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  subnet_id = "${data.aws_subnet_ids.subnet_ids.ids[1]}"

  #subnet_id     = "${resource.aws_subnet.subnet.id}"
  #subnet_id = "subnet-0b50c0aa88a0bf882"

  tags = {
    Name = "ubuntu-server"
  }
}
