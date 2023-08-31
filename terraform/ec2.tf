resource "aws_launch_configuration" "k8s-cluster" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg1.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "k8s-cluster" {
  name               = "terraform-asg-k8s-cluster-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg1.id]
  subnets            = [aws_subnet.subnet1a.id,aws_subnet.subnet1b.id]
}

resource "aws_autoscaling_group" "k8s-cluster" {
  min_size             = 1
  max_size             = 5
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.k8s-cluster.name
  vpc_zone_identifier  = [aws_subnet.subnet1a.id,aws_subnet.subnet1b.id]
}

resource "aws_lb_target_group" "k8s-cluster" {
  name     = "aws-lb-target-group-k8s-cluster"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
}

resource "aws_autoscaling_attachment" "k8s-cluster" {
  autoscaling_group_name = aws_autoscaling_group.k8s-cluster.id
  lb_target_group_arn   = aws_lb_target_group.k8s-cluster.arn
}

resource "aws_instance" "ec2-02" {
  ami                  = "ami-f95875ab"
  instance_type        = "t2.small"
  security_groups      = [aws_security_group.sg2.id]
  subnet_id            = aws_subnet.subnet2a.id
  monitoring           = false
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}
