#!/bin/bash
#获取本sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))
#加载配置文件
source $INITDIR/../init/init.conf
SOFT_HOME=$SOFT_INSTALL_DIR/$INSTALL_SOFT
mv $SOFT_HOME/conf/myid $SOFT_HOME/data
myidNum=1
echo 1 > $SOFT_HOME/data/myid
for node in `cat $INITDIR/../init/slaves`
do
    myidNum=`expr $myidNum + 1`
    ssh -q $SOFT_USER@$node "echo $myidNum > $SOFT_HOME/data/myid"
done
