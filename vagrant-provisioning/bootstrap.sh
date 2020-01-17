#!/bin/bash

## Set TimeZone to Asia/Ho_Chi_Minh
echo "===== [TASK] Set TimeZone to Asia/Ho_Chi_Minh"
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
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

## Update hosts file
echo "[TASK] Update host file /etc/hosts"
cat >>/etc/hosts<<EOF
192.168.16.151 docker1.testlab.local docker1
192.168.16.141 jenkins1.testlab.local jenkins1
192.168.16.130 kmaster.testlab.local kmaster
192.168.16.131 kworker1.testlab.local kworker1
192.168.16.132 kworker2.testlab.local kworker2
EOF

## Install Jenkins on CentOS 7
echo ">>>>> [TASK] Install Jenkins on CentOS 7"
yum -y install java-1.8.0-openjdk >/dev/null 2>&1
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins >/dev/null 2>&1
systemctl daemon-reload
systemctl start jenkins
systemctl enable jenkins >/dev/null 2>&1


## Cleanup system >/dev/null 2>&1
echo ">>>>> [TASK] Cleanup system"
package-cleanup -y --oldkernels --count=1
yum -y autoremove
yum clean all
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c
