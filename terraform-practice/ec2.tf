# Region Defined in s3.tf file

# Key-value pair
resource aws_key_pair my_key_pair {
  key_name = "terra-ec2-key"
  public_key = file("terra-ec2-key.pub")
}


# VPC Default
resource aws_default_vpc default {
}

# Security Group
resource aws_security_group my_sg {
  name = "terra-sg"
  vpc_id = aws_default_vpc.default.id   # interpolation
  description = "This is inbound and outbound security group."
}

# Inbound and Outbound Port Rules
resource aws_vpc_security_group_ingress_rule allow_http {
  security_group_id = aws_security_group.my_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource aws_vpc_security_group_egress_rule allow_traffic {
  security_group_id = aws_security_group.my_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"            #semantically equivalent to all ports
}


# Instance
resource aws_instance my_instance {
  tags = {
    Name = "terra-auto-server"
  }
  ami = "ami-091138d0f0d41ff90"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name = aws_key_pair.my_key_pair.key_name

  #Root Storage (EBS)
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
}

resource "aws_ec2_instance_state" "my_instance_state" {
  instance_id = aws_instance.my_instance.id
  state = "running"
}