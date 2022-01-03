output "vpc_id" {
  value = aws_vpc.app.id
}

output "subnet_1_id" {
  value = aws_subnet.one.id
}

output "subnet_1_az" {
  value = aws_subnet.one.availability_zone
}

output "subnet_2_id" {
  value = aws_subnet.two.id
}

output "subnet_2_az" {
  value = aws_subnet.two.availability_zone
}
