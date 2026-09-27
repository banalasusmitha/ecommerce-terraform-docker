# ---------------------------------------------------------------
# EC2 instance that runs all 5 Docker containers
# ---------------------------------------------------------------

# Find the latest official Ubuntu 22.04 image (AMI) published by Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (the company behind Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Upload our public SSH key to AWS so we can log in with the matching private key
resource "aws_key_pair" "app" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.module}/${var.public_key_path}")
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.app.key_name
  associate_public_ip_address = true

  # Startup script: installs Docker, pulls the 5 images and runs the containers.
  # templatefile() fills in the Docker Hub username and image tag.
  # replace() removes Windows line endings (\r) in case the file was saved on Windows.
  user_data = replace(templatefile("${path.module}/user_data.sh.tpl", {
    dockerhub_username = var.dockerhub_username
    image_tag          = var.image_tag
  }), "\r", "")

  # If the startup script changes, rebuild the instance so the new script runs
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }
}
