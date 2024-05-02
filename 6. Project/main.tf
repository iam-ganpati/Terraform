provider "aws" {
    region = "us-east-1"  
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "my_vpc"
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      Name = "subnet1"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "subnet2"
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "my_igw"
    }
}

resource "aws_route_table" "my_rt" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
      Name = "my_rt"
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
}

resource "aws_route_table_association" "rt_1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.my_rt.id
}

resource "aws_route_table_association" "rt_2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.my_rt.id
}

resource "aws_security_group" "my_sg" {
    name = "my_sg"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = "HTTP from VPC"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "allow ssh"
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
      Name = "my_sg"
    }
}

resource "aws_key_pair" "example" {
  key_name   = "gk-terraform"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}


resource "aws_instance" "my_instance" {
    count = 2
    ami = "ami-0a699202e5027c10d"
    instance_type = "t2.micro"
    key_name = aws_key_pair.example.key_name
    vpc_security_group_ids = [aws_security_group.my_sg.id]
    subnet_id = count.index == 0 ? aws_subnet.subnet1.id : aws_subnet.subnet2.id
 
    connection {
    type        = "ssh"
    user        = "ec2-user"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key
    host        = self.public_ip
  }

  # File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ec2-user/app.py"  # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo yum update -y",  # Update package lists (for ubuntu)
      "sudo yum install -y python3-pip",  # Example package installation
      "cd /home/ec2-user",
      "sudo pip3 install flask",
      "echo 'sudo python3 /home/ec2-user/app.py &' >> /home/ec2-user/start_app.sh",
      "sudo chmod +x /home/ec2-user/start_app.sh",
      "sudo /home/ec2-user/start_app.sh"
    ]
  }
}

resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = true

  tags = {
    Name = "my_lb"
  }
}

resource "aws_lb_target_group" "my_TG" {
  name = "my-TG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "lb_TG" {
  count            = length(aws_instance.my_instance)
  target_group_arn = aws_lb_target_group.my_TG.arn
  target_id        = aws_instance.my_instance[count.index].id  
  port             = 80 
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_TG.arn
    type = "forward"
  }
}
