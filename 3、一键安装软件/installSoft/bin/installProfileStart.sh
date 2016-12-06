#!/bin/bash
#如果非安装用户，退出安装
if [ $USER != "root" ]; then
echo "这个脚本必须用root执行！！！"
exit
fi
#获取本sh文件的绝对路径
readonly SHTDIR=$(readlink -m $(dirname $0))
INITDIR=`echo $SHTDIR|awk -F/ '{for(i=(NF-2);i++<(NF-1);){for(j=0;j++<i;){printf j==i?$j"\n":$j"/"}}}'`

#加载配置文件
source $INITDIR/init/init.conf
sh $INITDIR/init/installProfile.sh
#发送hadoop文件到其他节点
for slave in `cat $INITDIR/init/slaves`
do
    scp -r $INITDIR/init root@$slave:/tmp 
	ssh -q root@$slave "sh /tmp/init/installProfile.sh"
	ssh -q root@$slave "source /etc/profile"
done
for slave in `cat $INITDIR/init/slaves`
do
    ssh -q root@$slave "rm -rf /tmp/init"
done


