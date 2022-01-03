resource "aws_security_group" "efs" {
  name   = "${var.app}-efs"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.ingress_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { App = var.app }
}

resource "aws_efs_file_system" "app_server_efs" {
  tags = { App = var.app }
}

# create a mount for each subnet
resource "aws_efs_mount_target" "efs-mounts" {
  count           = length(var.subnet_ids.*)
  file_system_id  = aws_efs_file_system.app_server_efs.id
  subnet_id       = element(var.subnet_ids.*, count.index)
  security_groups = [aws_security_group.efs.id]
}
