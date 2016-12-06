#!/bin/bash
if [ $USER != "root" ]; then
echo "请用root用户操作！"
exit
fi

#获取当前sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))/../

#加载配置文件
source $INITDIR/conf/init.conf

#安装依赖包
for node in $INSTALL_SOFT_LIST ; do
    yum -y install $node
	echo "$node 安装成功！"
done

#关闭防火墙
service iptables stop
chkconfig iptables off
A=`service iptables status`
if [ $A == "iptables：未运行防火墙。" ]; then
echo "防火墙已经关闭！"
else
echo "防火墙关闭失败！退出shell！"
exit
fi

#关闭selinux
setenforce 0
B=`getenforce`
if [ $B == "Permissive" -o $B == "disabled" ]; then
echo "selinux已经关闭！"
else
echo "selinux关闭失败！退出shell！"
exit
fi

#配置域名hosts、如果域名不存在，配置就好
cat $INITDIR/conf/host.conf |while  read node
do
     array=( $node )
        # if host or ip is not exist in /etc/hosts, then add.
        if [ -z "`grep "${array[0]}" /etc/hosts`" -o -z "`grep "${array[1]}" /etc/hosts`" ]; then
                echo $node >> /etc/hosts
        fi
done
echo "配置/etc/hosts成功"

#检查是否安装了jdk
allreadyJDK=`rpm -qa | grep java`
#-z string 如果 string 长度为零，则为真               [ -z $myvar ]
#-n string  如果 string 长度非零，则为真        [ -n $myvar ]
#判断不为空
if [ -n "$allreadyJDK" ]; then
rpm -e --nodeps $allreadyJDK
echo "卸载openjdk成功"
fi

#添加用户
if [ $IF_INSTALL_OTHER_USER -eq 1 ]; then
groupadd $HADOOP_GROUP
useradd -g $HADOOP_GROUP $HADOOP_USER
$INITDIR/expect/password.expect $HADOOP_USER $HADOOP_PASSWORD >/dev/null 2>&1
echo "配置"$HADOOP_USER"用户信息成功"
fi
cp $INITDIR/file/sshd_config /etc/ssh/
service sshd restart
echo "重启ssh服务成功"
