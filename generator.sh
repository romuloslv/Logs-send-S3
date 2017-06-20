#!/bin/bash

Generator ()
{

# out default json nginx
for ((i=1; i<=10000; i++))
do
        echo -e ""\|""\"time\": \"${TIMEACCESS[$RANDOM % 8]}:$[($RANDOM % 24)]:$[($RANDOM % 24)]:$[($RANDOM % 60)]\", \
        "\|"\"remote_addr\": \"${IPS[$RANDOM % 10]}\", "\|"\"remote_user\": \"-\", "\|"\"body_bytes_sent\": \"133\", \
        "\|"\"request_time\": \"${CONT[$RANDOM % 3000]}\", "\|"\"status\": \"${HTTP[$RANDOM % 7]}\", "\|"\"request\": \
        \"GET /favicon.ico HTTP/1.1 ${RESOURCES[$RANDOM % 8]}\", "\|"\"request_method\": \"GET\", "\|"\"http_referrer\": \
        \"${REFERERS[$RANDOM % 4]}\", "\|"\"http_user_agent\": \"${USERAGENTS[$RANDOM % 8]}\""" > $HOME/$ACCESSDTRLT.log.$i
done

mkdir $ACCESSDTABS
vector_split=($(find . -name "$ACCESSDTRLT*" | cut -d'.' -f5))

# treatment of ifs for json format
for ((i=0; i<${#vector_split[*]}; i++))
do
        while read line
        do
                echo -e "{" $line | cut -d '|' -f1-500 --output-delimiter=$'\n \t'
                echo -e "}"
        done < $ACCESSDTRLT.log.${vector_split[$i]} > $ACCESSDTABS/$ACCESSDTRLT.log.${vector_split[$i]}
        rm -rf $ACCESSDTRLT.log.${vector_split[$i]}
done

rsync -arzhe ssh $ACCESSDTABS root@xxx.xxx.xxx.xxx:/var/log/mail
rm -rf $ACCESSDTABS
}

Generator;
