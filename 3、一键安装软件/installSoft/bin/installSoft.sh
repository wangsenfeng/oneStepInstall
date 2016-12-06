#!/bin/bash

#获取本sh文件的绝对路径
readonly SHTDIR=$(readlink -m $(dirname $0))
INITDIR=`echo $SHTDIR|awk -F/ '{for(i=(NF-2);i++<(NF-1);){for(j=0;j++<i;){printf j==i?$j"\n":$j"/"}}}'`

#加载配置文件
source $INITDIR/init/init.conf

#如果非安装用户，退出安装
if [ $USER != $SOFT_USER ]; then
echo "大哥，你配置文件中说好了用"$SOFT_USER"用户安装！但是现在为啥用"$USER"啊？退出重安！！！"
exit
fi

rm -rf $SOFT_INSTALL_DIR/$INSTALL_SOFT

#下载软件
wget -P $INITDIR/soft $SOFT_DOWNLOAD_PATH

#获取需要安装的软件
echo "您正在安装的软件为："$INSTALL_SOFT
SOFT_FILE_ZIP=`ls $INITDIR/soft | grep $INSTALL_SOFT | head -n 1`



#将安装文件拷贝到需要安装的目录下
echo "正在拷贝安装包$INITDIR/soft/$SOFT_FILE_ZIP到安装目录$SOFT_INSTALL_DIR下……"
cp $INITDIR/soft/$SOFT_FILE_ZIP $SOFT_INSTALL_DIR

#进入安装目录
echo "进入安装目录$SOFT_INSTALL_DIR下……"
cd $SOFT_INSTALL_DIR

#解压
echo "正在解压$SOFT_INSTALL_DIR/$SOFT_FILE_ZIP……"
tar -zxvf $SOFT_INSTALL_DIR/$SOFT_FILE_ZIP >/dev/null 2>&1

#删除压缩文件
echo "删除安装包$SOFT_INSTALL_DIR/$SOFT_FILE_ZIP……"
rm -rf $SOFT_INSTALL_DIR/$SOFT_FILE_ZIP

#查找安装文件的名字
SOFT_FILE_DIR=`ls $SOFT_INSTALL_DIR | grep $INSTALL_SOFT`

#重命名
echo "将安装文件$SOFT_INSTALL_DIR/$SOFT_FILE_DIR 重命名成$SOFT_INSTALL_DIR/$INSTALL_SOFT……"
mv $SOFT_INSTALL_DIR/$SOFT_FILE_DIR $SOFT_INSTALL_DIR/$INSTALL_SOFT

#配置环境变量
SOFT_HOME=$SOFT_INSTALL_DIR/$INSTALL_SOFT

#修改配置文件,如果是hadoop，特殊点
if [ $INSTALL_SOFT == 'hadoop' ]; then
cp $INITDIR/conf/$INSTALL_SOFT/* $SOFT_HOME/etc/hadoop
cd $SOFT_HOME
NAME_DIR=namedir
DATA_DIR=datadir
TMP=tmp
JN_DIR=jndir
HADOOP_MRSYS=hadoopmrsys
HADOOP_MRLOCAL=hadoopmrlocal
NODEMANAGER_LOCAL=nodemanagerlocal
NODEMANAGER_LOG=nodemanagerlogs
mkdir -m 755 $SOFT_HOME/$NAME_DIR
mkdir -m 755 $SOFT_HOME/$DATA_DIR
mkdir -m 755 $SOFT_HOME/$TMP
mkdir -m 755 $SOFT_HOME/$JN_DIR
mkdir -m 755 $SOFT_HOME/$HADOOP_MRSYS
mkdir -m 755 $SOFT_HOME/$HADOOP_MRLOCAL
mkdir -m 755 $SOFT_HOME/$NODEMANAGER_LOCAL
mkdir -m 755 $SOFT_HOME/$NODEMANAGER_LOG

elif [ $INSTALL_SOFT == 'zookeeper' ]; then
mkdir -m 755 $SOFT_HOME/data
mkdir -m 755 $SOFT_HOME/log
cp $INITDIR/conf/$INSTALL_SOFT/* $SOFT_HOME/conf
cp $INITDIR/lib/$INSTALL_SOFT/* $SOFT_HOME/lib

elif [ $INSTALL_SOFT == 'jdk' ]; then
echo 'nothing to do'
else
cp $INITDIR/conf/$INSTALL_SOFT/* $SOFT_HOME/conf
cp $INITDIR/lib/$INSTALL_SOFT/* $SOFT_HOME/lib
fi

#发送hadoop文件到其他节点
for slave in `cat $INITDIR/init/slaves`
do
   echo "正在发送文件$SOFT_HOME到$SOFT_USER@$slave……" 
   scp -r $SOFT_HOME $SOFT_USER@$slave:$SOFT_INSTALL_DIR
done

#格式化集群
if [ $INSTALL_SOFT == 'hadoop' ]; then
$INITDIR/others/formatHadoop.sh
fi
if [ $INSTALL_SOFT == 'zookeeper' ]; then
$INITDIR/others/formatZookeeper.sh
fi
if [ $INSTALL_SOFT == 'kafka' ]; then
$INITDIR/others/formatKafka.sh
fi
