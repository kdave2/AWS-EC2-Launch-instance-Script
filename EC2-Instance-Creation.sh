#!/bin/bash

# This file is used for launching ec2 instance through command line 
# before executing this file some prerequisite steps has to be followed
# 1. Install AWS Cli and for that we need to have python installed on machine.
# 2. Then we need to configure aws to identify your account.
# 3. For that you need Access Key and Security Access Key which can be obtained from AWS Security Credentials
# and download the file or save it where it is secure and don't provide that or share that information with anybody.

# The purpose of this script is to create 5 instance of ec2 and launch them ensuring everything is in free tier.

# Defining array conatining name of ec2 instance.

instanceNames=('LoadBalancer' 'Server1' 'Server2' 'Server3' 'Server4')
count="0"

while [ $count -lt 5 ]
do

echo ${instanceNames[count]}
instanceId=$(aws ec2 run-instances --image-id ami-xxxxxxxx --security-group-ids sg-xxxxxxxx --count 1 --instance-type t2.micro --key-name key-pair.pem --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":8,\"DeleteOnTermination\":true}}]" --user-data install-nginx.sh --query 'Instances[0].InstanceId' | sed 's/.//;s/.$//')
echo $instanceId

times=0
echo
while [ 30 -gt $times ] && ! aws ec2 describe-instances --instance-ids $instanceId| grep -q "running"
do
  times=$(( $times + 1 ))
  echo Attempt $times at verifying $instanceId is running...
done

echo

if [ 5 -eq $times ]; then
  echo Instance $instanceId is not running. Exiting...
  exit
fi
succes=$(aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=${instanceNames[count]})
echo $succes
ipaddress=$(aws ec2 describe-instances --instance-ids $instanceId --query 'Reservations[0].Instances[0].PublicIpAddress')
echo $ipaddress
count=$[$count+1]
done

 
    

