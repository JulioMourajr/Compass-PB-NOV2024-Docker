resource "aws_instance" "wordpress-instance1a" {
  ami                         = "ami-0c614dee691cbbf37"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.privada-app-A.id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = false
  key_name                    = "wordpress-key"

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_endpoint  = aws_db_instance.rds.endpoint,
    efs_dns_name = aws_efs_file_system.wordpress_efs.dns_name
  }))

  tags = {
    Name       = "PB - NOV 2024"
    CostCenter = "C092000024"
    Project    = "PB - NOV 2024"
  }

  volume_tags = {
    Name       = "PB - NOV 2024"
    CostCenter = "C092000024"
    Project    = "PB - NOV 2024"
  }
}

resource "aws_instance" "wordpress-instance1b" {
  ami                         = "ami-0c614dee691cbbf37"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.privada-app-B.id
  vpc_security_group_ids      = [aws_security_group.wordpress_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = false
  key_name                    = "wordpress-key"

  tags = {
    Name       = "PB - NOV 2024"
    CostCenter = "C092000024"
    Project    = "PB - NOV 2024"
  }

  volume_tags = {
    Name       = "PB - NOV 2024"
    CostCenter = "C092000024"
    Project    = "PB - NOV 2024"
  }
}