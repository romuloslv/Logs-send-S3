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

# For manual delete the line 26 and line 87 to 93
:<<'manualy'
InputM ()
{

INTERFACES=$(ip l | cut -d ':' -f 2 | grep -v ^[0-9] | grep -v ^[a-z] | egrep -v "lo")
VINTERFACES=($INTERFACES)
MACS=$(ip link | awk '/ether/ {print $2}' | sed 's/:/-/g')
VMACS=($MACS)

echo "Enter the interface corresponding to the mac that will be used when creating the bucket!"
echo
echo "$INTERFACES"
echo
echo -n ":"
read MAC
echo

for ((i=0; i<${#VINTERFACES[*]}; i++))
do
if [ $MAC = ${VINTERFACES[$i]} ]
then
        j=0;
else
        let j++
fi
done

if [ $j -eq ${#VINTERFACES[*]} ]
then
        unset j;
        InputM;
fi

case "$MAC" in

        ${VINTERFACES[0]})
            BCKT=${VMACS[0]}-logs
            ;;

        ${VINTERFACES[1]})
            BCKT=${VMACS[1]}-logs
            ;;

        ${VINTERFACES[2]})
            BCKT=${VMACS[2]}-logs
            ;;

        ${VINTERFACES[3]})
            BCKT=${VMACS[3]}-logs
            ;;

        ${VINTERFACES[4]})
            BCKT=${VMACS[4]}-logs
            ;;
esac

}

Forward ()
{

InputM;
manualy

Forward ()
{

BCKT=$(ip link | awk '/ether/ {print $2}' | sed 's/:/-/g')-logs

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

# Disaster recovery
if [ $? -eq 0 ]
then
        rm -rf $ACCESSDTABS
        if [ -f $HOME/policy.json  ]
        then
                rm $HOME/policy.json
        fi
else
        while [ $(ls $HOME | grep access.2017 | wc -l) -ne 0 ]
        do
                bkp_dir=$(ls $HOME | grep access.2017)
                vector_bkp=($bkp_dir)
                for((i=0; i<${#vector_bkp[*]}; i++))
                do
                        aws s3 cp --recursive ${vector_bkp[$i]} s3://$BCKT/recovered/${vector_bkp[$i]}
                        if [ $? -eq 0 ]
                        then
                                rm -rf ${vector_bkp[$i]}
                                rm $HOME/policy.json
                        fi
                done
        done
        aws s3 rm s3://$BCKT/$ACCESSDTRLT/
fi
}

Forward;
