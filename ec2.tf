resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow-ssh.id]
  key_name = aws_key_pair.mykey.id 
  associate_public_ip_address = true
  user_data = filebase64("app-install.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 2
  max_size             = 4
  vpc_zone_identifier = [aws_subnet.main-public.id]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers = [aws_elb.my-elb.name]
  force_delete              = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}
