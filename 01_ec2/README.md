# EFS Demo

Creates one EBS-only instance and instance with an instance store. 
Each instance has a dedicated EBS device, and a shared EFS device.

## TODO

* Multi-attach EBS

## Setup

```
aws ec2 create-key-pair --key-name EfsDemo --query 'KeyMaterial' --output text > EfsDemo.pem
chmod 400 EfsDemo.pem
```
*See [Creating, displaying, and deleting Amazon EC2 key pairs](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html) 
for more details.*
   

## Deploy

```bash
terraform init
terraform apply
```

## EBS Only

1. Connect to instance
```
ssh ec2-user@{ebs_only_ip} -i EfsDemo.pem
```

2. Find 1GB EBS device
```
lsblk
```

3. Create file system (required once only)

```
sudo mkfs -t xfs /dev/nvme1n1
```

4. Mount EBS device

```
mkdir ~/ebs 
sudo mount /dev/nvme1n1 ~/ebs
```

*See [Make an Amazon EBS volume available for use on Linux](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html) 
for more details*

## Instance Store

1. Connect to instance
```
ssh ec2-user@{instance_store_ip} -i EfsDemo.pem
```

2. Find 1GB EBS device
```
lsblk
```

3. Create file system (required once only)

```
sudo mkfs -t xfs /dev/nvme2n1
```

4. Mount EBS device

```
mkdir ~/ebs 
sudo mount /dev/nvme2n1 ~/ebs
```

5. Find 55GB+ instance store device
```
lsblk
```

6. Create file system (required once only)
```
sudo mkfs -t xfs /dev/nvme1n1
```

7. Mount instance store
```
mkdir ~/tmp
sudo mount /dev/nvme1n1 ~/tmp
```

*See [Add instance store volumes to your EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/add-instance-store-volumes.html)
for more details.*

## EFS

```bash
ssh ec2-user@{ebs_only_ip} -i EfsDemo.pem
mkdir ~/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport {efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/ efs
sudo touch ~/efs/hi_instance_store

ssh ec2-user@{instance_store_ip} -i EfsDemo.pem
mkdir ~/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport {efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/ efs
sudo touch ~/efs/hi_ebs_only
```

*See [EFS User Guide > Mount the file system on the EC2 instance and test](https://docs.aws.amazon.com/efs/latest/ug/wt1-test.html)
for more details.*

## Verify 

1. `df -h` on EBS-only instance

```
/dev/nvme0n1p1                                           8.0G  1.6G  6.5G  20% /
/dev/nvme1n1                                            1014M   34M  981M   4% /home/ec2-user/ebs
{efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/  8.0E     0  8.0E   0% /home/ec2-user/efs
```

2. `df -h` on instance store instance
```
/dev/nvme0n1p1                                           8.0G  1.6G  6.4G  21% /
/dev/nvme2n1                                            1014M   34M  981M   4% /home/ec2-user/ebs
/dev/nvme1n1                                              55G   89M   55G   1% /home/ec2-user/tmp
{efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/  8.0E     0  8.0E   0% /home/ec2-user/efs
```

3. `ls -l ~/efs` on both instances

```
-rw-r--r-- 1 root root 0 Jan  3 06:35 hi_ebs_only
-rw-r--r-- 1 root root 0 Jan  3 06:35 hi_instance_store
```

## Cleanup

```
terraform destroy
aws ec2 delete-key-pair --key-name EfsDemo
rm EfsDemo.pem
```