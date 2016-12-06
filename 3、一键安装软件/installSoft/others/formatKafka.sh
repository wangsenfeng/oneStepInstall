#!/bin/bash
#获取本sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))
#加载配置文件
source $INITDIR/../init/init.conf
SOFT_HOME=$SOFT_INSTALL_DIR/$INSTALL_SOFT
mkdir -m 755 $SOFT_HOME/kafka-logs
HOST_NAME=`hostname`
cat $SOFT_HOME/config/server.properties | sed 's/MYBROKERID/1/g' > $SOFT_HOME/config/server.properties
cat $SOFT_HOME/config/server.properties | sed 's/MYHOSTNAME/$HOST_NAME/g' > $SOFT_HOME/config/server.properties
for node in `cat $INITDIR/init/slaves`
do
    ssh -q $SOFT_USER@$node "cat $SOFT_HOME/config/server.properties | sed 's/MYBROKERID/1/g' > $SOFT_HOME/config/server.properties"
	ssh -q $SOFT_USER@$node "cat $SOFT_HOME/config/server.properties | sed 's/MYHOSTNAME/$HOST_NAME/g' > $SOFT_HOME/config/server.properties"
done
