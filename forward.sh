#!/bin/bash

Login ()
{

# generate aws credentials
if [ ! -e $HOME/.aws/credentials ] || [ ! -e $HOME/.aws/config ]
then
        if [ ! -d $HOME/.aws ]
        then
                mkdir $HOME/.aws
        fi
cat > $HOME/.aws/$1 << EOF
[default]
$2
$3
EOF
fi
}

Login "credentials" "aws_access_key_id=yourkeyid" "aws_secret_access_key=yoursecretkey"
Login "config" "region=yourzone" "output=yourformat"

Forward ()
{

vector_logs=($(ls /var/log/mail))

for ((i=0; i<${#vector_logs[*]}; i++))
do
BCKT=$(echo ${vector_logs[$i]}-logs)

# search and create bucket
aws s3 ls | grep -o $BCKT

if [ $? -ne 0 ]
then
    aws s3api create-bucket --bucket $BCKT --create-bucket-configuration LocationConstraint=us-west-2

    # create policy and apply on bucket
    cat > $HOME/policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "s3:GetBucketAcl",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::$BCKT",
            "Principal": { "Service": "logs.us-west-2.amazonaws.com" }
        },
        {
            "Action": "s3:PutObject" ,
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::$BCKT/*",
            "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } },
            "Principal": { "Service": "logs.us-west-2.amazonaws.com" }
        }
    ]
}
EOF
    aws s3api put-bucket-policy --bucket $BCKT --policy file://$HOME/policy.json
fi

# create directory and upload of files
aws s3api put-object --bucket $BCKT --key $ACCESSDTRLT/
aws s3 cp --recursive $ACCESSDTABS/ s3://$BCKT/$ACCESSDTRLT

done
}

Forward;
