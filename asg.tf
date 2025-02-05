resource "aws_launch_template" "wordpress_template" {
  name          = "wordpress-template"
  image_id      = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
  key_name      = "wordpress-key"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    subnet_id                   = aws_subnet.privada-app-A.id
    security_groups             = [aws_security_group.wordpress_sg.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name       = "PB - NOV 2024"
      CostCenter = "C092000024"
      Project    = "PB - NOV 2024"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name       = "PB - NOV 2024"
      CostCenter = "C092000024"
      Project    = "PB - NOV 2024"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_endpoint  = aws_db_instance.rds.endpoint,
    efs_dns_name = aws_efs_file_system.wordpress_efs.dns_name
  }))

}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "wordpress-asg"
  vpc_zone_identifier = [aws_subnet.privada-app-A.id, aws_subnet.privada-app-B.id]
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  health_check_type   = "ELB"
  target_group_arns   = [aws_lb_target_group.wordpress_target_group.arn]

  launch_template {
    id = aws_launch_template.wordpress_template.id
  }
}

resource "aws_autoscaling_policy" "wp_asg_policy" {
  name                   = "wp-asg-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 2
  }
}

