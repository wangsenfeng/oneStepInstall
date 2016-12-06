#!/bin/bash
#获取当前sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))
#卸载jdk
rm -rf /usr/java
rm -rf /usr/jdk
cp $INITDIR/profile /etc/
cp $INITDIR/hosts /etc/
userdel hadoop
rm -rf /home/hadoop
cp $INITDIR/sshd_config /etc/ssh/
service sshd restart
source /etc/profile
su - root
