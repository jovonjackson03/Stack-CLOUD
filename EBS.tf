#Create EC2 instance to mount EBS
# EC2 instance
resource "aws_instance" "web" {
    ami           = var.AMIS["us-east-1"] #"ami-0742b4e673072066f"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    security_groups = ["wordpress_test_security_group"]
    user_data = file("EBS_Bootstrap.sh")
    key_name = "MyEC2KeyPairCSA"
    tags = {
    "Name" = "EBS_TF"
    }
}

#Create EBS Volume
resource "aws_ebs_volume" "u01" {
    availability_zone = "us-east-1a"
    size              = 8
    tags = {
    "Name" = "u01"
    }
}

resource "aws_ebs_volume" "u02" {
    availability_zone = "us-east-1a"
    size              = 8
    tags = {
    "Name" = "u02"
    }
}

resource "aws_ebs_volume" "u03" {
    availability_zone = "us-east-1a"
    size              = 8
    tags = {
    "Name" = "u03"
    }
}

resource "aws_ebs_volume" "u04" {
    availability_zone = "us-east-1a"
    size              = 8
    tags = {
    "Name" = "u04"
    }
}

#EBS Volume Attachment
resource "aws_volume_attachment" "ebs_u01" {
    device_name = "/dev/sdb"
    volume_id   = aws_ebs_volume.u01.id
    instance_id = aws_instance.web.id
    force_detach = true
}

resource "aws_volume_attachment" "ebs_u02" {
    device_name = "/dev/sdc"
    volume_id   = aws_ebs_volume.u02.id
    instance_id = aws_instance.web.id
    force_detach = true
}

resource "aws_volume_attachment" "ebs_u03" {
    device_name = "/dev/sdd"
    volume_id   = aws_ebs_volume.u03.id
    instance_id = aws_instance.web.id
    force_detach = true
}

resource "aws_volume_attachment" "ebs_u04" {
    device_name = "/dev/sde"
    volume_id   = aws_ebs_volume.u04.id
    instance_id = aws_instance.web.id
    force_detach = true
}

