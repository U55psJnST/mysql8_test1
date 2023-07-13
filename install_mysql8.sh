

#!/bin/bash
#与后面endtime结合现实脚本安装时间
start_time=$(date +%s)
 
#安装mysql依赖包，如果没有，后面可能报错
yum -y install gcc gcc-c++ openssl openssl-devel libaio libaio-devel  ncurses  ncurses-devel  >> /dev/null
 
#mysql官网下载64位的二进制版本:mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz ，置于/software目录下
tar  xvfJ  /software/mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz  -C  /usr/local/
mv  /usr/local/mysql-8.0.17-linux-glibc2.12-x86_64  /usr/local/mysql8
 
 
#创建mysql组和用户
groupadd mysql
useradd -d /home/mysql -g mysql -m mysql
echo  111111 | passwd  --stdin  mysql 

#root 建立软链接  -- 以后操作 /data ，
mkdir /data555
ln -s /data555  /data     

mkdir -p  /data/u01/mysqldb
chown -R  mysql.mysql  /data/u01/mysqldb
mkdir -p  /data/u02/mysqllog
chown -R  mysql.mysql  /data/u02/mysqllog

#配置 /root/11/my.cnf， 把 my.cnf 放到 /data/u01/mysqldb/ 下
cp /root/11/my.cnf  /data/u01/mysqldb/my.cnf
chown -R  mysql.mysql  /data/u01/mysqldb

#修改 server_id 等信息
sh /root/11/2.sh


#root进行如下操作
mkdir -p /data/u01/mysqldb/run/
mkdir -p /data/u01/mysqldb/data
mkdir -p /data/u01/mysqldb/tmp
mkdir -p /data/u01/mysqldb/share/english
mkdir -p /data/u02/mysqllog/undo
mkdir -p /data/u02/mysqllog/log/binlog
mkdir -p /data/u02/mysqllog/log/iblog
mkdir -p /data/u02/mysqllog/log/relaylog
cp /usr/local/mysql8/share/english/errmsg.sys  /data/u01/mysqldb/share/english

chown -R  mysql.mysql  /data/u01/mysqldb
chown -R  mysql.mysql  /data/u02/mysqllog


#配置环境变量  , mysql执行
echo "export PATH=$PATH:/usr/local/mysql8/bin"  >>  /home/mysql/.bash_profile
source /home/mysql/.bash_profile

echo "export PATH=$PATH:/usr/local/mysql8/bin"  >>  /root/.bash_profile
source /root/.bash_profile

 
#初始化数据库
/usr/local/mysql8/bin/mysqld  --defaults-file=/data/u01/mysqldb/my.cnf  --initialize  --user=mysql --basedir=/data/u01/mysqldb/  --datadir=/data/u01/mysqldb/data/   >>  /dev/null

#打开mysql 或者执行 sh start.sh
/usr/local/mysql8/bin/mysqld_safe --defaults-file=/data/u01/mysqldb/my.cnf  --user=mysql  &



echo "#####mysql8安装完成#####"

sleep 10s 
 
#修改mysql登录密码
b=`grep  'temporary password'   /data/u02/mysqllog/log/error.log`
a=`echo ${b##*localhost:}`
echo $a
 


#mysql -e　可以直接在命令行执行命令, 111111 是设定的新密码
/usr/local/mysql8/bin/mysql -uroot -p"${a}" -S  /data/u01/mysqldb/run/mysql.sock -e  "ALTER USER 'root'@'localhost'  IDENTIFIED  BY '111111'"  --connect-expired-password
echo  "#####mysql8密码修改成功#####"
 
echo  'mysql  -uroot -p111111 -hlocalhost -P2455 -S  /data/u01/mysqldb/run/mysql.sock ' > /home/mysql/login_root.sh
echo  'mysqld_safe --defaults-file=/data/u01/mysqldb/my.cnf  --user=mysql  & ' > /home/mysql/startup.sh
echo  'mysqladmin -uroot -p111111  -P2455  -S  /data/u01/mysqldb/run/mysql.sock    shutdown   & ' > /home/mysql/shutdown.sh

chown -R mysql.mysql /home/mysql/

end_time=$(date +%s)
cost_time=$((end_time - start_time))
echo $cost_time




