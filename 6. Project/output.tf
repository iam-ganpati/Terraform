output "my_vpc" {
    description = "VPC has been created, vpc id is:"
    value = aws_vpc.my_vpc.id
}

output "subnet1" {
    description = "subnet1 created, subnet1 id is:"
    value = aws_subnet.subnet1.id  
}

output "subnet2" {
    description = "subnet1 created, subnet2 id is:"
    value = aws_subnet.subnet2.id  
}

output "my_igw" {
    description = "igw created, igw id is :"
    value = aws_internet_gateway.my_igw.id
}

output "my_rt" {
    description = "route table created"
    value = aws_route_table.my_rt.id
}

output "my_sg" {
    description = "security group created, name for the security group is:"
    value = aws_security_group.my_sg.name  
}

output "my_lb" {
    description = "load balancer created, dns name is: "
    value = aws_lb.my_lb.dns_name
}

output "my_TG" {
    description = "TG has been created and id is:"
    value = aws_lb_target_group.my_TG.id 
}

output "my_instance_ids" {
  description = "IDs of the EC2 instances created"
  value       = aws_instance.my_instance[*].id
}
