#!/bin/bash

#如果非安装用户，退出安装
if [ $USER != "root" ]; then
echo "这个脚本必须用root执行！！！"
exit
fi

#获取本sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))

#加载配置文件
source $INITDIR/init.conf
#配置环境变量
SOFT_HOME=$SOFT_INSTALL_DIR/$INSTALL_SOFT
SOFT_HOME_PROFILE=$(echo $INSTALL_SOFT | tr '[a-z]' '[A-Z]')_HOME

if [ -z "`grep "$SOFT_HOME_PROFILE" /etc/profile`" -o -z "`grep "$SOFT_INSTALL_DIR/$INSTALL_SOFT" /etc/profile`" ]; then
   
	if [ $INSTALL_SOFT == "jdk" -a -z "`grep "CLASSPATH" /etc/profile`" ]; then
		echo "export JAVA_HOME=$SOFT_INSTALL_DIR/$INSTALL_SOFT" >> /etc/profile
		echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
		echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
	else
		if [ $INSTALL_SOFT != "jdk" ]; then
		echo "export $SOFT_HOME_PROFILE=$SOFT_INSTALL_DIR/$INSTALL_SOFT" >> /etc/profile
		echo 'export PATH=$PATH:$'"$SOFT_HOME_PROFILE/bin" >> /etc/profile
		fi
	fi
fi


