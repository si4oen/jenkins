#!/bin/bash

## Set TimeZone to Asia/Ho_Chi_Minh
echo ">>>>> [TASK] Set TimeZone to Asia/Ho_Chi_Minh"
timedatectl set-timezone Asia/Ho_Chi_Minh

## Update the system >/dev/null 2>&1
echo ">>>>> [TASK] Updating the system"
yum install -y epel-release >/dev/null 2>&1
yum update -y >/dev/null 2>&1

## Install desired packages
echo ">>>>> [TASK] Installing desired packages"
yum install -y telnet htop net-tools wget nano >/dev/null 2>&1

## Enable password authentication
echo ">>>>> [TASK] Enabled SSH password authentication"
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
systemctl reload sshd

## Set Root Password
echo ">>>>> [TASK] Set root password"
echo "centos" | passwd --stdin root >/dev/null 2>&1

## Disable and Stop firewalld
echo ">>>>> [TASK] Disable and stop firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

## Disable SELinux
echo ">>>>> [TASK] Disable SELinux"
setenforce 0 >/dev/null 2>&1
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

## Update hosts file
echo ">>>>> [TASK] Update host file /etc/hosts"
cat >>/etc/hosts<<EOF
192.168.16.161 gitlab1.testlab.local gitlab1
192.168.16.151 docker1.testlab.local docker1
192.168.16.141 jenkins1.testlab.local jenkins1
192.168.16.130 kmaster.testlab.local kmaster
192.168.16.131 kworker1.testlab.local kworker1
192.168.16.132 kworker2.testlab.local kworker2
EOF

## Install Jenkins on CentOS 7
echo ">>>>> [TASK] Install Jenkins & Git on CentOS 7"
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel >/dev/null 2>&1
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo >/dev/null 2>&1
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum -y install jenkins >/dev/null 2>&1
systemctl daemon-reload
systemctl start jenkins
systemctl enable jenkins >/dev/null 2>&1

## Install Python3.x & pip3 & git
echo ">>>>> [TASk] Install Python3.x & pip & git"
yum install -y git >/dev/null 2>&1
yum install -y centos-release-scl >/dev/null 2>&1
yum install -y rh-python36 >/dev/null 2>&1
yum install -y python3-pip >/dev/null 2>&1

## Cleanup system >/dev/null 2>&1
echo ">>>>> [TASK] Cleanup system"
package-cleanup -y --oldkernels --count=1 >/dev/null 2>&1
yum -y autoremove >/dev/null 2>&1
yum clean all >/dev/null 2>&1
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c

## Rebooting Server
echo ">>>>> [TASK] Rebooting server"
echo ""
echo "########## Finished ##########"
sudo reboot now
