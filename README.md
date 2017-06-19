# Laboratory

The system below provides a simulation of logging HTTP requests from a web server in addition to sending these logs to a s3 bucket in AWS. More details of the scenario and the tools used for the tests will be presented below.

The following conditions were met:

**Products used on AWS: EC2 (t2.micro) | S3 (Bucket)**

```
Release   | General Availability Date | redhat-release Errata Date*  | Kernel Version
RHEL 7.3  |        2016-11-03	      | 2016-11-03 RHSA-2016:2574-1  |  3.10.0-514
```

```bash
[ec2-user@hostname ~]$ cat /proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 62
model name	: Intel(R) Xeon(R) CPU E5-2670 v2 @ 2.50GHz
stepping	: 4
microcode	: 0x415
cpu MHz		: 2493.803
cache size	: 25600 KB
physical id	: 0
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 13
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology eagerfpu pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm fsgsbase smep erms xsaveopt
bogomips	: 4988.11
clflush size	: 64
cache_alignment	: 64
address sizes	: 46 bits physical, 48 bits virtual
power management:

[ec2-user@hostname ~]$ free -m
              total        used        free      shared  buff/cache   available
Mem:            991          79         738          12         172         741
Swap:             0           0           0

[ec2-user@hostname ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda2       10G  1,9G  8,2G  19% /
devtmpfs        472M     0  472M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M   13M  483M   3% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
tmpfs           100M     0  100M   0% /run/user/1000

[ec2-user@hostname ~]$ uname -r
3.10.0-514.2.2.el7.x86_64
```

## Prerequisites

* [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os) x tools
* yum x build source

Download the scripts and place them in the default user's home by changing their access credentials in AWS in "forward.sh"

```bash
[ec2-user@hostname ~]$ sudo chmod 755 *.sh && sudo chown ec2-user:ec2-user *.sh
[ec2-user@hostname ~]$ sudo yum update && sudo yum upgrade -y
[ec2-user@hostname ~]$ sudo yum install vim wget cur unzip patch gcc gcc-c++ kernel-devel make -y
[ec2-user@hostname ~]$ sudo mkdir 1755 /daemon && sudo cd /daemon
[ec2-user@hostname ~]$ sudo wget https://cr.yp.to/daemontools/daemontools-0.76.tar.gz && sudo wget http://installer-djbdns.ps2v.com/djbpatches.tar.gz
[ec2-user@hostname ~]$ sudo gunzip daemontools-0.76.tar && sudo tar -xpf daemontools-0.76.tar && sudo tar xvfz djbpatches.tar.gz
[ec2-user@hostname ~]$ sudo mkdir patchs && sudo mv -f *.patch patchs && sudo rm -f daemontools-0.76.tar djbpatches.tar.gz
[ec2-user@hostname ~]$ sudo patch /daemon/admin/daemontools-0.76/src/error.h patchs/daemontools-0.76.errno.patch
[ec2-user@hostname ~]$ sudo cd admin/daemontools-0.76 && sudo package/install && sudo mkdir -p /daemon/services/requisitions
[ec2-user@hostname ~]$ sudo rm -rf /daemon/patchs && sudo cd /daemon/services/requisitions/ &&  sudo vim run
#!/bin/bash

exec 2>&1
exec setuidgid ec2-user /home/ec2-user/./variables.sh
[ec2-user@hostname ~]$ sudo chmod 755 run && sudo mkdir -p log/main && sudo vim log/run
#!/bin/bash

exec setuidgid ec2-user multilog t ./main
[ec2-user@hostname ~]$ sudo chmod 755 log/run && sudo ln -s /daemon/services/requisitions /service/ && sudo chown -R ec2-user:ec2-user /daemon
[ec2-user@hostname ~]$ sudo vim /lib/systemd/system/daemontools.service
[Unit]
Description=DJB daemontools
After=sysinit.target

[Service]
ExecStart=/command/svscanboot
Restart=always

[Install]
WantedBy=multi-user.target
[ec2-user@hostname ~]$ sudo ln -s /lib/systemd/system/daemontools.service /etc/systemd/system/multi-user.target.wants/daemontools.service
[ec2-user@hostname ~]$ sudo ln -s /daemon/services/requisitions /service/
```
After restarting the machine, you should be able to see something like this

```bash
[ec2-user@hostname daemon]$ pwd && ls -l *
/daemon
admin:
total 0
lrwxrwxrwx. 1 ec2-user ec2-user 16 Jan 12 10:09 daemontools -> daemontools-0.76
drwxr-xr-x. 6 ec2-user ec2-user 62 Jan 12 10:09 daemontools-0.76

services:
total 0
drwxr-xr-x. 4 ec2-user ec2-user 45 Jan 12 14:37 requisitions
[ec2-user@hostname services]$ pwd && ls -l *
/daemon/services
total 4
drwxr-xr-x. 4 ec2-user ec2-user 46 Jan 12 12:08 log
-rwxr-xr-x. 1 ec2-user ec2-user 77 Jan 12 12:08 run
drwx------. 2 ec2-user ec2-user 57 Jan 12 14:37 supervise
[ec2-user@hostname log]$ pwd && ls -l *
/daemon/services/requisitions/log
-rwxr-xr-x. 1 ec2-user ec2-user   55 Jan 12 12:08 run

main:
total 880
-rwxr--r--. 1 root     root     98085 Jan 12 12:07 @400000005877b7f8193f7294.s
-rwxr--r--. 1 root     root     98366 Jan 12 12:07 @400000005877b7f81980c154.s
-rwxr--r--. 1 root     root     98014 Jan 12 12:07 @400000005877b7f81a49aaec.s
-rwxr--r--. 1 root     root     98074 Jan 12 12:07 @400000005877b7f81b4ee5ec.s
-rwxr--r--. 1 root     root     98307 Jan 12 12:07 @400000005877b7f81c538894.s
-rwxr--r--. 1 root     root     98133 Jan 12 12:07 @400000005877b7f81d5404bc.s
-rwxr--r--. 1 root     root     98222 Jan 12 12:07 @400000005877b7f81e4cd40c.s
-rwxr--r--. 1 root     root     98111 Jan 12 12:07 @400000005877b7f81f46e794.s
-rwxr--r--. 1 root     root     98076 Jan 12 12:07 @400000005877b7f81fefd5ac.s
-rwxr--r--. 1 ec2-user ec2-user  4988 Jan 12 14:37 current
-rw-------. 1 ec2-user ec2-user     0 Jan 12 11:49 lock
-rw-r--r--. 1 ec2-user ec2-user     0 Jan 12 14:24 state

supervise:
total 4
prw-------. 1 ec2-user ec2-user  0 Jan 12 14:37 control
-rw-------. 1 ec2-user ec2-user  0 Jan 12 11:41 lock
prw-------. 1 ec2-user ec2-user  0 Jan 12 11:41 ok
-rw-r--r--. 1 root     root     18 Jan 12 14:37 status
```
Now it is possible to monitor the process of requesting in real time through the daemon.

```bash
[ec2-user@hostname ~]$ ps faux | grep ec2-user
root       462  0.0  0.1 115244  1488 ?        Ss   14:30   0:00 /bin/sh /command/svscanboot
root       469  0.0  0.0   4340   472 ?        S    14:30   0:00  \_ svscan /service
root       473  0.0  0.0   4168   424 ?        S    14:30   0:00  |   \_ supervise requisitions
ec2-user 24637  0.0  0.1  11628  1492 ?        S    20:05   0:00  |   |   \_ /bin/bash /home/ec2-user/./variables.sh
ec2-user 24641  0.0  0.0   4320   356 ?        S    20:05   0:00  |   |       \_ sleep 60
root       474  0.0  0.0   4168   344 ?        S    14:30   0:00  |   \_ supervise log
ec2-user 24638  0.0  0.0   4180   340 ?        S    20:05   0:00  |       \_ multilog t ./main
root       470  0.0  0.0   4156   344 ?        S    14:30   0:00  \_ readproctitle service errors: .....................
```
Supervise monitors a service. It starts the service and restarts the service if it dies. Setting up a new service is easy: all supervise needs is a directory with a run script that runs the service. Multilog saves error messages to one or more logs. It optionally timestamps each line and, for each log, includes or excludes lines matching specified patterns. It automatically rotates logs to limit the amount of disk space used. If the disk fills up, it pauses and tries again, without losing any data.

[More info](https://cr.yp.to/daemontools/faq/create.html)

* svc -d (stop service)
* svc -u (service restart)

[More info](https://cr.yp.to/daemontools/svc.html)

```bash
[ec2-user@hostname ~]$ svc -d /daemon/services/requisitions/ /daemon/services/requisitions/log/
[ec2-user@hostname ~]$ svstat /daemon/services/requisitions/ /daemon/services/requisitions/log/
/daemon/services/requisitions/: down 362 seconds, normally up
/daemon/services/requisitions/log/: down 362 seconds, normally up
[ec2-user@hostname ~]$ svc -u /daemon/services/requisitions/ /daemon/services/requisitions/log/
[ec2-user@hostname ~]$ svstat /daemon/services/requisitions/ /daemon/services/requisitions/log/
/daemon/services/requisitions/: up (pid 24672) 3 seconds
/daemon/services/requisitions/log/: up (pid 24673) 3 seconds
```
When your service stops for some unexpected reason, the daemon automatically raises it. Everything is stored in the log folder of the daemon itself, ideal to know if your services are working as expected.

### Example of success in sending logs to bucket s3
```bash
[ec2-user@hostname ~]$ tail -f /daemon/services/requisitions/log/main/current 
upload: access.2017-01-12-14:34:00/access.2017-01-12-14:34:00.log.aa to s3://35.167.147.111-logs/access.2017-01-12-14:34:00/access.2017-01-12-14:34:00.log.aa
@400000005877dae32be5ffbc mkdir: cannot create directory '/home/ec2-user/.aws/credentials': File exists
@400000005877dae61ff76efc {
@400000005877dae61ff772e4     "Location": "http://35.167.147.111-logs.s3.amazonaws.com/"
@400000005877dae61ff776cc }
@400000005877dae63aab572c {
@400000005877dae63aab5b14     "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\""
@400000005877dae63aab5efc }
upload: access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.ab to s3://35.167.147.111-logs/access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.ab
upload: access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.aa to s3://35.167.147.111-logs/access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.aa
```
[More info](https://cr.yp.to/daemontools/multilog.html)

It is still possible to convert the format of the timestamp using tai64nlocal, see:

```bash
[ec2-user@hostname ~]$ tail -f /daemon/services/requisitions/log/main/current | tai64nlocal
upload: access.2017-01-12-14:34:00/access.2017-01-12-14:34:00.log.aa to s3://35.167.147.111-logs/access.2017-01-12-14:34:00/access.2017-01-12-14:34:00.log.aa
2017-01-12 14:36:57.736493500 mkdir: cannot create directory '/home/ec2-user/.aws/credentials': File exists
2017-01-12 14:37:00.536309500 {
2017-01-12 14:37:00.536310500     "Location": "http://35.167.147.111-logs.s3.amazonaws.com/"
2017-01-12 14:37:00.536311500 }
2017-01-12 14:37:00.984307500 {
2017-01-12 14:37:00.984308500     "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\""
2017-01-12 14:37:00.984309500 }
upload: access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.ab to s3://35.167.147.111-logs/access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.ab
upload: access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.aa to s3://35.167.147.111-logs/access.2017-01-12-14:36:56/access.2017-01-12-14:36:56.log.aa
```
[More info](Https://cr.yp.to/daemontools/tai64nlocal.html)

### Example of error in sending logs to bucket s3

```bash
[ec2-user@hostname ~]$ tail -f /daemon/services/requisitions/log/main/current | tai64nlocal
2017-01-12 12:07:58.551761500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ grep -o 35.167.147.111-logs
2017-01-12 12:07:58.852933500 Unable to locate credentials. You can configure credentials by running "aws configure".
2017-01-12 12:07:58.878895500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ '[' 1 -eq 1 ']'
2017-01-12 12:07:58.878896500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ aws s3api create-bucket --bucket 35.167.147.111-logs --create-bucket-configuration LocationConstraint=us-west-2
2017-01-12 12:07:59.199930500 Unable to locate credentials. You can configure credentials by running "aws configure".
2017-01-12 12:07:59.218535500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ aws s3api put-object --bucket 35.167.147.111-logs --key access.2017-01-12-12:07:58/
2017-01-12 12:07:59.543930500 Unable to locate credentials. You can configure credentials by running "aws configure".
2017-01-12 12:07:59.566149500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ aws s3 cp --recursive access.2017-01-12-12:07:58/ s3://35.167.147.111-logs/access.2017-01-12-12:07:58
2017-01-12 12:07:59.929158500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ rm -rf access.2017-01-12-12:07:58
2017-01-12 12:07:59.929863500 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ sleep 60
```
### Optimization

* Almost null writing and reading (disk), absolute paths and High priority level.

### Out default nginx

```bash
[ec2-user@hostname ~]$ tail -n1 access.log

198.51.100.232 - - [10/Jan/2017:13:06:27 -0300] "GET /test HTTP/1.1" 304 0 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0"
```

### Out default json nginx

```bash
[ec2-user@hostname ~]$ tail -n1 access.log

"time": "2017-01-11T09:18:04-03:00", "remote_addr": "198.51.100.232", "remote_user": "-", "body_bytes_sent": "133", "request_time": "0.000", "status": "200", "request": "GET /favicon.ico HTTP/1.1", "request_method": "GET", "http_referrer": "-", "http_user_agent": "Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0"
```

### Out default json script nginx

```bash
[ec2-user@hostname ~]$ tail -n1 access.2017-01-13-09\:30\:22.log.aa
{ 
 	"time": "2017-01-01T:2:6:49", 
 	"remote_addr": "8.8.8.8", 
 	"remote_user": "-", 
 	"body_bytes_sent": "133", 
 	"request_time": "2414", 
 	"status": "403", 
 	"request": "GET /favicon.ico HTTP/1.1 /empresa", 
 	"request_method": "GET", 
 	"http_referrer": "https://www.99jobs.com", 
 	"http_user_agent": "Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.0)"
}
```
