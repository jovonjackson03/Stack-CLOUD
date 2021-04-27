###Stack EC2 TF script###

#create EFS File System
resource "aws_efs_file_system" "efs" {
}

#create a mount target
resource "aws_efs_mount_target" "mount" {
    file_system_id = aws_efs_file_system.efs.id
    security_groups = [aws_security_group.allow_alot.id]
    subnet_id = aws_default_subnet.default.id
    }

#create mount point
resource "null_resource" "configure_nfs" {
    depends_on = [aws_efs_mount_target.mount]
    connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = aws_instance.web.public_ip
}
}

# Deafult VPC
resource "aws_default_vpc" "default" {
}


#default subnet
resource "aws_default_subnet" "default" {
    availability_zone = "us-east-1a"
}

#create instance profile
resource "aws_iam_instance_profile" "tf_ec2_profile" {
    role = aws_iam_role.S3_role.name
}

# EC2 instance
resource "aws_instance" "web" {
    ami           = var.AMIS["us-east-1"] #"ami-0742b4e673072066f"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.allow_alot.name]
}

#create role with full S3 access for instance profile
resource "aws_iam_role" "S3_role" {
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
    "Effect": "Allow",
    "Sid": ""
    }
    ]
}
EOF
}

#create policy for Role
resource "aws_iam_policy" "S3_policy" {
    description = "A test policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
    }
    ]
}
EOF
}

#attach policy to Role
resource "aws_iam_role_policy_attachment" "S3-attach" {
    role       = aws_iam_role.S3_role.name
    policy_arn = aws_iam_policy.S3_policy.arn
}


#Launch Configuration
resource "aws_launch_configuration" "WP_LC" {
    image_id      = "ami-0742b4e673072066f"
    instance_type = "t2.micro"
    #key_name = var.PATH_TO_PUBLIC_KEY
    security_groups = [aws_security_group.allow_alot.id]
    user_data = templatefile("BOOTSTRAP1.sh",{ 
        FILE_SYSTEM_ID = aws_efs_file_system.efs.id,
        REGION = var.AWS_REGION,
        MOUNT_POINT = "/var/www/html" })
}

#Autoscaling Policy
resource "aws_autoscaling_policy" "WP_ASG" {
    name                   = "TF_WP_ASG"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 30
    autoscaling_group_name = aws_autoscaling_group.ASG.name
    }

#Autoscaling Group
resource "aws_autoscaling_group" "ASG" {
    max_size                  = 3
    desired_capacity          = 2
    min_size                  = 1
    health_check_grace_period = 30
    health_check_type         = "EC2"
    force_delete              = true
    launch_configuration      = aws_launch_configuration.WP_LC.name
    vpc_zone_identifier       = [aws_default_subnet.default.id]
}


#Create a Security Group
resource "aws_security_group" "allow_alot" {
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_default_vpc.default.id
}

resource "aws_security_group_rule" "HTTPS" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}


resource "aws_security_group_rule" "HTTP" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}

resource "aws_security_group_rule" "SSH" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}

resource "aws_security_group_rule" "DNS_UDP" {
    type              = "ingress"
    from_port         = 53
    to_port           = 53
    protocol          = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}


resource "aws_security_group_rule" "DNS_TCP" {
    type              = "ingress"
    from_port         = 53
    to_port           = 53
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}


resource "aws_security_group_rule" "MYSQL_AURORA" {
    type              = "ingress"
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}


resource "aws_security_group_rule" "NFS" {
    type              = "ingress"
    from_port         = 2049
    to_port           = 2049
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}

resource "aws_security_group_rule" "all" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.allow_alot.id
}


resource "aws_volume_attachment" "ebs_att" {
    device_name = "/dev/sdb"
    volume_id   = aws_ebs_volume.Volume_1.id
    instance_id = aws_instance.web.id
}

resource "aws_ebs_volume" "Volume_1" {
    availability_zone = "us-east-1a"
    size              = 1
}