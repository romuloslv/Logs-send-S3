#!/bin/bash

Variables ()
{

export HOME="/home/ec2-user"
export DT="$(date +%Y-%m-%d-%H:%M:%S)"
export ACCESSDTRLT="access.$DT"
export ACCESSDTABS="$HOME/$ACCESSDTRLT"
export HTTP=("200" "301" "400" "401" "403" "404" "500")
export CONT="($(for((i=2000; i<5000; i++)) do echo $i; done))"
export TIMEACCESS=("2017-01-01T" "2017-01-11T" "2017-01-06T" "2017-01-08T" "2017-01-13T" "2017-01-05T" "2017-01-15T" "2017-01-03T")
export IPS=("50.63.202.37" "52.202.73.151" "184.168.221.2" "52.21.65.43" "8.8.8.8" "8.8.4.4" "208.67.222.222" "208.67.220.220" "84.200.69.80" "84.200.70.40")
export REFERERS=("https://www.99jobs.com" "https://br.linkedin.com/company" "https://web.whatsapp.com" "https://mobile.twitter.com/romuloslv")
export RESOURCES=("/vagas" "/blog" "/empresa" "/contato" "/login" "/cases" "/anunciantes" "/in-loco-media/jobs/9748-sre-engineer-junior-trainee")
export USERAGENTS=("Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.0)"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1944.0 Safari/537.36"
"Mozilla/5.0 (Linux; U; Android 2.3.5; en-us; HTC Vision Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
"Mozilla/5.0 (iPad; CPU OS 9_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25"
"Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201"
"Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0"
"Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))"
"Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0")

source $HOME/./generator.sh

}

Variables;
