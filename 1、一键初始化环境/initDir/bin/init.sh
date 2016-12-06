#!/bin/bash


#判断用户是否是root
if [ $USER != "root" ]; then
echo "请用root用户操作！"
exit
fi
#获取当前sh文件的绝对路径的上一层目录
readonly INITDIR=$(readlink -m $(dirname $0))
#加载配置文件
source $INITDIR/../conf/init.conf
#将初始化文件夹分发下去
srcDir=`echo $INITDIR|awk -F/ '{for(i=(NF-2);i++<(NF-1);){for(j=0;j++<i;){printf j==i?$j"\n":$j"/"}}}'`
desDir=`echo $INITDIR|awk -F/ '{for(i=(NF-3);i++<(NF-2);){for(j=0;j++<i;){printf j==i?$j"\n":$j"/"}}}'`
cat $INITDIR/../conf/host.conf |while  read node
do
	array=( $node )
	localhost=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
	echo ${array[0]}
	if [[ $localhost =~ ${array[0]} ]]; then
	$INITDIR/start.sh
	else
	$INITDIR/../expect/scp.expect $srcDir ${array[0]} $USER $ROOT_PASSWORD $desDir
    	$INITDIR/../expect/otherInit.expect $INITDIR ${array[0]} $USER $ROOT_PASSWORD
	fi
done








