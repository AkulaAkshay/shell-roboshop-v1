#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="akshaysunny.space"
hosted_zone="Z02237942WL8S6DN4RI1T"


for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
            --image-id ${ami_id} \
            --instance-type ${instance_type} \
            --security-groups "roboshop-common"  "roboshop-$instance" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
            --query 'Instances[0].InstanceId' \
            --output text
    )

    echo "Launched ${instance} Instance ID: $INSTANCE_ID"
done



