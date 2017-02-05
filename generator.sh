#!/bin/bash

# For manual delete the line 4 and line 28 to 34
:<<'manualy'
Input ()
{

echo
echo "Enter the number of logs to be generated!"
echo
echo -n :
read NLOGS
echo

if [ $(echo $NLOGS | grep -c '^[0-9]\+$') = 0 ] || [ $NLOGS -eq 0 ]
then
        echo "Only positive numbers!";
        Input;
fi

}

Generator ()
{

Input;

for ((i=1; i<=$NLOGS; i++))
manualy

Generator ()
{

# out default json nginx
for ((i=1; i<=10000; i++))
do
        echo -e ""\|""\"time\": \"${TIMEACCESS[$RANDOM % 8]}:$[($RANDOM % 24)]:$[($RANDOM % 24)]:$[($RANDOM % 60)]\", \
        "\|"\"remote_addr\": \"${IPS[$RANDOM % 10]}\", "\|"\"remote_user\": \"-\", "\|"\"body_bytes_sent\": \"133\", \
        "\|"\"request_time\": \"${CONT[$RANDOM % 3000]}\", "\|"\"status\": \"${HTTP[$RANDOM % 7]}\", "\|"\"request\": \
        \"GET /favicon.ico HTTP/1.1 ${RESOURCES[$RANDOM % 8]}\", "\|"\"request_method\": \"GET\", "\|"\"http_referrer\": \
        \"${REFERERS[$RANDOM % 4]}\", "\|"\"http_user_agent\": \"${USERAGENTS[$RANDOM % 8]}\""" >> $HOME/$ACCESSDTRLT.log
done

# redundancy and scalability
uniq $ACCESSDTRLT.log >> $HOME/log
mkdir $ACCESSDTABS
split -l 500 $HOME/log $ACCESSDTRLT.log.
vector_split=($(ls $ACCESSDTRLT.log.* | cut -d'.' -f4))
rm -f $HOME/log $ACCESSDTRLT.log

# treatment of ifs for json format
for ((i=0; i<${#vector_split[*]}; i++))
do
        while read line
        do
                echo -e "{" $line | cut -d '|' -f1-500 --output-delimiter=$'\n \t'
                echo -e "}"
        done < $ACCESSDTRLT.log.${vector_split[$i]} >> $ACCESSDTABS/$ACCESSDTRLT.log.${vector_split[$i]}
        rm -rf $ACCESSDTRLT.log.${vector_split[$i]}
done

source $HOME/./forward.sh

}

Generator;
