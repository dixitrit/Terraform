##### Resource Block ###################
resource "aws_vpc" "my_vpc_canada"{
         cidr_block = var.cidr
 tags = {
    Name = "MyVPC"
  }
}

####Creating public subnet#######
resource "aws_subnet" "pub_sub" {
         count      = 2
         vpc_id     = aws_vpc.my_vpc_canada.id
         cidr_block = "10.0.${count.index + 1}.0/24"
         availability_zone = var.azs[count.index]
         map_public_ip_on_launch = true

         tags = {
          Name = "PublicSubnet-${count.index + 1}"
        }
}

####Creating private Subnet #############
resource "aws_subnet" "priv_sub" {
        count    =  2
        vpc_id   = aws_vpc.my_vpc_canada.id
        cidr_block = "10.0.${count.index + 3}.0/24"
        availability_zone = var.azs[count.index]

        tags = {
         Name = "PrivateSubnet-${count.index + 1}"
     }
}

###### Creating Internet Gateway #########
resource "aws_internet_gateway" "igw" {
       vpc_id = aws_vpc.my_vpc_canada.id

       tags = {
         Name = "MyInternetGW"
   }
}

#####Creating NAT Gateway ########
resource "aws_eip" "nat_gateway_eip" {
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id   = aws_eip.nat_gateway_eip.id
  subnet_id       = aws_subnet.pub_sub[1].id
  depends_on      = [aws_internet_gateway.igw]

  tags = {
    Name = "MyInternetGW"
  }
}

######## Creating  Public Route table ########
resource "aws_route_table" "Public_RT" {
       vpc_id = aws_vpc.my_vpc_canada.id
       route {
          cidr_block = "0.0.0.0/0"
          gateway_id = aws_internet_gateway.igw.id
    }
   tags = {
    Name = "PublicRouteTable"
  }
}

### Associate public route table with public subnets ####
resource "aws_route_table_association" "pub_sub_association" {
   count       = 2
   subnet_id   = aws_subnet.pub_sub[count.index].id
   route_table_id   = aws_route_table.Public_RT.id
}

######## Creating Private Route Table ########

resource "aws_route_table" "Private_RT" {
   count = 2
   vpc_id = aws_vpc.my_vpc_canada.id

   tags = {
     Name = "PrivateRouteTable-${count.index + 1}"
   }
}

resource "aws_route" "private_route" {
   route_table_id    = aws_route_table.Private_RT[1].id
   destination_cidr_block = "0.0.0.0/0"
   nat_gateway_id     = aws_nat_gateway.my_nat_gateway.id
}
#### Associate private route table with private subnets #####

    ###### Private without NAT ######
resource "aws_route_table_association" "priv_sub_association_0" {
   subnet_id  = aws_subnet.priv_sub[0].id
   route_table_id = aws_route_table.Private_RT[0].id
}


   ##### Private with NAT #######
resource "aws_route_table_association" "priv_sub_association_1" {
   subnet_id    = aws_subnet.priv_sub[1].id
   route_table_id   = aws_route_table.Private_RT[1].id
}



###### Creating security Group #######
resource "aws_security_group" "Test_SG" {
   name = "Test_SG_Name"
   vpc_id = aws_vpc.my_vpc_canada.id

   ingress {
      description = "HTTP from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks  = ["0.0.0.0/0"]
   }

   ingress {
     description = "Https from VPC"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks  = ["0.0.0.0/0"]
   }

   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port  = 0
     to_port    = 0
     protocol   = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "Test-sg"
   }
}

######## AWS S3 Busket Creation ##############
resource "aws_s3_bucket" "rit-test-bucket" {
   bucket = "ritesh-terraform-test"
}

##### Creating AWS key Pair ##########
resource "aws_key_pair" "example" {
  key_name = "example_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "Pub-server" {
   count = 2
   ami  = "ami-0a2e7efb4257c0907"
   instance_type = "t2.micro"
   key_name = aws_key_pair.example.key_name
   vpc_security_group_ids  = [aws_security_group.Test_SG.id]
   subnet_id    = aws_subnet.pub_sub[count.index].id

   tags = {
    Name = "PublicInstance-${count.index + 1}"
  }
}

resource "aws_instance" "Priv_server" {
    ami = "ami-0a2e7efb4257c0907"
    instance_type = "t2.micro"
    key_name = aws_key_pair.example.key_name
    vpc_security_group_ids = [aws_security_group.Test_SG.id]
    subnet_id = aws_subnet.priv_sub[0].id
    tags = {
    Name = "PrivateInstance-1"
   }
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.pub_sub[*].id

  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "MyALB"
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc_canada.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb_sg"
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc_canada.id

  health_check {
    enabled             = true
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 2
  }
  tags = {
    Name = "MyTargetGroup"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.Pub-server[0].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.Pub-server[1].id
  port             = 80
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
}

##### Output the subnet ID

output "public_subnet_ids" {
  value = aws_subnet.pub_sub[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.priv_sub[*].id
}

output "public_instance_ids" {
  value = aws_instance.Pub-server[*].id
}

output "private_instance_ids" {
  value = aws_instance.Priv_server[*].id
}

output "loadbalancerdns" {
  value = aws_lb.my_alb.dns_name
}

output "my_nat_gateway_id_output" {
  value = aws_nat_gateway.my_nat_gateway.id
}
