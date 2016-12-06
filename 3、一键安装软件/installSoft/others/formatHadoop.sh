#!/bin/bash
#获取本sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))
#加载配置文件
source $INITDIR/../init/init.conf
source $INITDIR/node.conf
SOFT_HOME=$SOFT_INSTALL_DIR/$INSTALL_SOFT
#修改从resourcemanager的配置文件
ssh -q $SOFT_USER@$RESOURCE_MANAGER_BACKUP "cp $SOFT_HOME/etc/hadoop/yarn-site.xml2 $SOFT_HOME/etc/hadoop/yarn-site.xml"
#格式化active的zkfc
for node in $NAME_NODE_ACTIVES ; do
        ssh -q $SOFT_USER@$node "$SOFT_HOME/bin/hdfs zkfc -formatZK"
done
#启动journalnode
for node in $JOURNAL_NODES ; do
        ssh -q $SOFT_USER@$node "$SOFT_HOME/sbin/hadoop-daemon.sh start journalnode"
		#监听journalnode是否已经启动
		while true;
		do
		startJN1=`ssh -q $SOFT_USER@$node 'netstat -anp | grep 8485 | wc -l'`
		if [ $startJN1 -eq 1 ];then
		break
		else
		echo "wait for $node 8485 starting......."
		sleep 1
		fi
		done
done
#格式化集群、启动active的namenode
for node in $NAME_NODE_ACTIVES ; do
       ssh -q $SOFT_USER@$node "$SOFT_HOME/bin/hdfs namenode -format -clusterId hadoopClustersOnline"
	   ssh -q $SOFT_USER@$node "$SOFT_HOME/sbin/hadoop-daemon.sh start namenode"
done
#格式化backup节点、启动backup的namenode
for node in $NAME_NODE_BACKUPS ; do
        ssh -q $SOFT_USER@$node "$SOFT_HOME/bin/hdfs namenode -bootstrapStandby"
		ssh -q $SOFT_USER@$node "$SOFT_HOME/sbin/hadoop-daemon.sh start namenode"
done
#启动zkfc
for node in $NAME_NODE_ACTIVES $NAME_NODE_BACKUPS ; do
        ssh -q $SOFT_USER@$node "$SOFT_HOME/sbin/hadoop-daemon.sh start zkfc"
done
#启动datanodes
for node in $DATA_NODES ; do
        ssh -q $SOFT_USER@$node "$SOFT_HOME/sbin/hadoop-daemon.sh start datanode"
done
#启动yarn
$SOFT_HOME/sbin/start-yarn.sh
#启动resourcemanager备份
ssh -q hadoop@master2 "cp /home/hadoop/hadoop/etc/hadoop/yarn-site.xml2 /home/hadoop/hadoop/etc/hadoop/yarn-site.xml"
ssh -q $SOFT_USER@$RESOURCE_MANAGER_BACKUP "$SOFT_HOME/sbin/yarn-daemon.sh start resourcemanager"
