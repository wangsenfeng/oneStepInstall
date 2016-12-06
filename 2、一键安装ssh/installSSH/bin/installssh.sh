#!/bin/bash
#获取本sh文件的绝对路径
readonly INITDIR=$(readlink -m $(dirname $0))
PROGDIR=`echo $INITDIR|awk -F/ '{for(i=(NF-2);i++<(NF-1);){for(j=0;j++<i;){printf j==i?$j"\n":$j"/"}}}'`
#加载配置文件
source $PROGDIR/conf/params.conf
if [ $USER != $INSTALL_USER ]; then
echo "你配置的用户是$INSTALL_USER,请用$INSTALL_USER用户操作！"
exit
fi
#删除ssh文件夹
rm -rf ~/.ssh
#创建ssh文件夹
mkdir -m 700 ~/.ssh
#进入ssh文件夹
cd ~/.ssh
#生成公私钥
$PROGDIR/expect/ssh_nopassword.expect
#将公钥加入公钥列表
cat id_rsa.pub >> authorized_keys
#授权
chmod 600 authorized_keys
cp $PROGDIR/testyes/letyesgo* ~/.ssh
cp $PROGDIR/conf/params.conf ~/.ssh
#将。ssh文件夹发送到其他机器
for node in $NODES ; do
        $PROGDIR/expect/scp.expect ~/.ssh $node $INSTALL_USER $INSTALL_PASSWORD
	echo "$node done."
done
for node in $NODES ; do
	    ssh -q $INSTALL_USER@$node "~/.ssh/letyesgo.sh"
done
