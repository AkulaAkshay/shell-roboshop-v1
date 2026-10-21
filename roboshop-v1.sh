#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="akshaysunny.space"
hosted_zone_id="Z02237942WL8S6DN4RI1T"


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

    if [ ${instance} != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids ${INSTANCE_ID} \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --output text
        )
        r53_record="${instance}.${domain_name}"

    else
        IP=$(aws ec2 describe-instances \
            --instance-ids ${INSTANCE_ID} \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text
        )
        r53_record="${domain_name}"
    fi

    #update r53 record
    aws route53 change-resource-record-sets \
            --hosted-zone-id ${hosted_zone_id} \
            --change-batch '{
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                    "Name": "'${r53_record}'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [{"Value": "'${IP}'"}]
                    }
                }
            ]
    }'

    echo "r53 record updated for Instance ID: $INSTANCE_ID"

done




