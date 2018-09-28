#!/bin/bash
mdb=mariadb-10.1.36.tar.gz
hostname=`hostname`

check_ok() {
if [ $? != 0 ]
then
	echo "ERROR!Check the log"
	exit 1
fi
}

myum() {
if ! rpm -qa|grep -q "^$1"
then
     yum install -y $1
check_ok
else
     echo $1 already installed.
fi 
}

for p in cmake ncurses-devel bison openssl openssl-devel unzip gcc ncurses-devel gcc-c++ libtool readline-devel
do
   myum $p
done

/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql

if [ "`hostname`" != "$hostname" ]
then
hostnamectl set-hostname $hostname
fi

if [ -d /data/mariadb-10.1 ]
then
	read -p "检测到/data/mariadb-10.1目录，若重新安装，则需要删除此目录。Y/N" v
	
if [ "$v" == "Y" ]
then
rm -rf /data/mariadb-10.1 && /bin/mkdir /data/mariadb-10.1/data -p
#create redo directory 
/bin/mkdir /data/mariadb-10.1/redolog -p
#create undo directory
/bin/mkdir /data/mariadb-10.1/undolog -p

mkdir mariadb-10.1 && tar zxf $mdb -C mariadb-10.1 --strip-components 1

cd mariadb-10.1

cmake -DCMAKE_INSTALL_PREFIX=/data/mariadb-10.1/ -DMYSQL_DATADIR=/data/mariadb-10.1/data -DMYSQL_UNIX_ADDR=/data/mariadb-10.1/data/mariadb.sock -DSYSCONFDIR=/etc -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DWITH_SSL=yes -DMYSQL_TCP_PORT=3306

make -j `grep processor /proc/cpuinfo | wc -l` && make install
check_ok

chown -R mysql.mysql /data/mariadb-10.1

chown mysql.root /data/mariadb-10.1

cp support-files/my-large.cnf /etc/my.cnf

cp support-files/mysql.server /etc/rc.d/init.d/mysqld && chmod 755 /etc/rc.d/init.d/mysqld

sed -i 's#^datadir = .*$#datadir = /data/mariadb-10.1/data#g' /etc/my.cnf

cat>/etc/systemd/system/mariadb.service<<EOF
 [Unit]
        Description=MariaDB server and services
        After=syslog.target
        After=network.target

        [Service]
        Type=simple
        User=mysql
        Group=mysql
        ExecStart=/data/mariadb-10.1/bin/mysqld_safe --basedir=/data/mariadb-10.1
        TimeoutSec=300
        PrivateTmp=false

        [Install]
        WantedBy=multi-user.target

EOF

cd /data/mariadb-10.1
./scripts/mysql_install_db --user=mysql --datadir=/data/mariadb-10.1/data
check_ok

systemctl enable mariadb.service
systemctl status mariadb.service

chkconfig --add mysqld
chkconfig  mysqld on

if grep -q mariadb /etc/profile
then
	echo "The enviroment for mariadb has been set."
else
echo "export PATH=/data/mariadb-10.1/bin:$PATH">>/etc/profile
echo "export LD_LIBRARY_PATH=/data/mariadb-10.1/lib/mysql:$LD_LIBRARY_PATH">>/etc/profile
source /etc/profile
fi

systemctl start mariadb.service

echo -e "\nMariadb is running.Use mysqladmin to set the root's password."

else 
	echo "Install quit!"
	exit 1
fi
fi
