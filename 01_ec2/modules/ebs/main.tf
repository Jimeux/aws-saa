resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.availability_zone
  type              = "gp3"
  size              = 1
  encrypted         = false
  tags              = { App = var.app }
}

resource "aws_volume_attachment" "ebs_only_ebs_attachment" {
  device_name = "/dev/sdh"
  instance_id = var.attachment_instance_id
  volume_id   = aws_ebs_volume.ebs_volume.id
}
