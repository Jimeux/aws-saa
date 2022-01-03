# aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*" --query 'sort_by(Images, &CreationDate)[].Name'
data aws_ssm_parameter amzn2_ami_x86_64 {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# aws ec2 describe-instance-types --instance-types c6gd.medium
data aws_ssm_parameter amzn2_ami_arm64 {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2"
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  id = "${var.app}-${random_id.id.hex}"
}

resource "aws_instance" "instance" {
  ami                  = var.ebs_only ? data.aws_ssm_parameter.amzn2_ami_x86_64.value : data.aws_ssm_parameter.amzn2_ami_arm64.value
  instance_type        = var.ebs_only ? "t3.micro" : "c6gd.medium"
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id            = var.subnet_id
  key_name             = var.key_name
  security_groups      = [aws_security_group.instance_sg.id]
  user_data            = file("${path.module}/user_data.sh")
  tags                 = { App = var.app }

  # Customise instance store(s)
  /*ephemeral_block_device {
    device_name  = "/dev/xvdc"
    virtual_name = "ephemeral0"
  }*/

  # Modify default root device. (An EBS volume.)
  # Only these four settings can be overridden.
  /*root_block_device {
    volume_size           = "16"
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }*/

  # Add an additional EBS device together with instance.
  /*ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "8"
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }*/
}

// https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.id}-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name               = "${local.id}-instance-role"
  assume_role_policy = file("${path.module}/assume_role_policy.json")
  tags               = { App : var.app }
}

resource "aws_iam_role_policy" "instance_policy" {
  name   = "${local.id}-instance-role-policy"
  role   = aws_iam_role.instance_role.id
  policy = file("${path.module}/instance_policy.json")
}

resource "aws_security_group" "instance_sg" {
  name        = "${local.id}-instance-sg"
  description = "Allow HTTP from Anywhere"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags        = { App = var.app }
}
