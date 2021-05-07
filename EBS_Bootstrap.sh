#!/bin/bash
#EBS Bootstrap
#update system
sudo yum update -y

#partition a disk in linux through script
ebs_vol="/dev/sdb /dev/sdc /dev/sdd /dev/sde"
for var in ${ebs_vol}
do
sudo fdisk $var <<EOT
n
p
1
2048
16777215
p
w
EOT
done

#create disk labels
pvcreate /dev/sdb1
pvcreate /dev/sdc1
pvcreate /dev/sdd1
pvcreate /dev/sde1

#Create volume group
vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

#create Logical Volumes (LUNS) with 5G of space 
lvcreate -L 5G -n Lv_u01 stack_vg
lvcreate -L 5G -n Lv_u02 stack_vg
lvcreate -L 5G -n Lv_u03 stack_vg
lvcreate -L 5G -n Lv_u04 stack_vg

#create ext4  filesystems on these logical volumes
mkfs.ext4 /dev/stack_vg/Lv_u01
mkfs.ext4 /dev/stack_vg/Lv_u02
mkfs.ext4 /dev/stack_vg/Lv_u03
mkfs.ext4 /dev/stack_vg/Lv_u04

#create mount points to hold space for logical volumes
mkdir /u01
mkdir /u02
mkdir /u03
mkdir /u04

#Mount logical volumes
mount /dev/stack_vg/Lv_u01 /u01
mount /dev/stack_vg/Lv_u02 /u02
mount /dev/stack_vg/Lv_u03 /u03
mount /dev/stack_vg/Lv_u04 /u04

#extend available disk size by 3G
lvextend -L +3G /dev/mapper/stack_vg-Lv_u01
lvextend -L +3G /dev/mapper/stack_vg-Lv_u02
lvextend -L +3G /dev/mapper/stack_vg-Lv_u03
lvextend -L +3G /dev/mapper/stack_vg-Lv_u04

#resize Logical Volumes to the new size 
resize2fs /dev/mapper/stack_vg-Lv_u01
resize2fs /dev/mapper/stack_vg-Lv_u02
resize2fs /dev/mapper/stack_vg-Lv_u03
resize2fs /dev/mapper/stack_vg-Lv_u04
