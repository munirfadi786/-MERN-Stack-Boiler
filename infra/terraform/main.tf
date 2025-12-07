resource "aws_iam_role" "cw_agent_role" {
  name = "cloudwatch_agent_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_cloudwatch_log_group" "mern_logs" {
  name              = "mern-app-logs"
  retention_in_days = 7

  tags = {
    Application = "mern-app"
  }
}

resource "aws_iam_instance_profile" "cw_agent_profile" {
  name = "cw_agent_profile"
  role = aws_iam_role.cw_agent_role.name
}

# Security Group for MERN App
resource "aws_security_group" "mern_sg" {
  name        = "${var.mern-app}-sg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.mern-app}-sg"
  }
}

# Launch Template for EC2
resource "aws_launch_template" "mern_lt" {
  name_prefix   = "${var.mern-app}-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type          
  key_name      = var.key_name
  
  # Add a dummy tag here to force a new version creation:
  tags = {
    DummyTag = "ForceUpdate" 
  }

  vpc_security_group_ids = [aws_security_group.mern_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.cw_agent_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.mern-app}-instance"
    }
  }
}

# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Resource to track the LT version and trigger the ASG update
resource "null_resource" "trigger_asg_update" {
  triggers = {
    # This value changes every time the launch template is updated
    launch_template_version = aws_launch_template.mern_lt.latest_version
  }
}


resource "aws_autoscaling_group" "mern_asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.desired_capacity + 1
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.mern_lt.id
    version = "$Latest"
  }
  
  # Explicit dependency forces ASG to re-evaluate when the trigger changes
  depends_on = [null_resource.trigger_asg_update]

  tag {
    key                 = "Name"
    value               = "${var.mern-app}-asg"
    propagate_at_launch = true
  }
}


# Application Load Balancer
resource "aws_lb" "mern_alb" {
  name               = "${var.mern-app}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mern_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "mern_tg" {
  name     = "${var.mern-app}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "mern_listener" {
  load_balancer_arn = aws_lb.mern_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mern_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.mern_asg.name
  lb_target_group_arn = aws_lb_target_group.mern_tg.arn
}

resource "null_resource" "run_ansible" {
  depends_on = [aws_autoscaling_group.mern_asg]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_SSH_ARGS          = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    }

    command = <<EOF
echo "Waiting 60 seconds for instances to become ready..."
sleep 60

echo "Switching to Ansible directory..."
cd "${path.module}/../ansible"

echo "Running Ansible Playbook..."
ansible-playbook -i aws_ec2.yml playbook.yml \
  --path to your key/mern-key.pem \
  --extra-vars "ansible_user=ubuntu"
EOF
  }
}
