#!/bin/bash

# 指定数据库安装包名称，将本脚本放在同一目录下
mdb=mariadb-10.1.36.tar.gz
hostname=`hostname`

#用于检查执行结果的函数
check_ok() {
if [ $? != 0 ]
then
	echo "ERROR!Check the log"
	exit 1
fi
}

#用于一键增加innodb等高级设置的函数
setcnf() {
cat>/etc/my.cnf<<EOF
[client]
#default-character-set = utf8
socket = /data/mariadb-10.1/data/mariadb-10.1.sock
port = 3306
[mysqld]
########basic settings########
datadir = /data/mariadb-10.1/data
socket = /data/mariadb-10.1/data/mariadb-10.1.sock
port = 3306
event_scheduler = ON
pid-file = /data/mariadb-10.1/data/mariadb-10.1.pid
symbolic-links = 0
user = mysql
thread_handling = pool-of-threads
lower_case_table_names = 1
skip-name-resolve
character_set_server = utf8
transaction_isolation = READ-COMMITTED
max_connections = 5000
max_connect_errors = 100000
table_open_cache = 4096
max_allowed_packet = 32M
init-connect = 'SET NAMES utf8'
read_rnd_buffer_size = 16M
read_buffer_size = 16M
sort_buffer_size = 2M
join_buffer_size = 2M
thread_cache_size = 30
thread_stack = 512K
query_cache_size = 512M
query_cache_type = 1
tmp_table_size = 512M
max_heap_table_size = 512M
binlog_cache_size = 4M
max_binlog_cache_size = 1G
max_binlog_size = 1G
key_buffer_size = 512M
#explicit_defaults_for_timestamp = 1
interactive_timeout = 1800
wait_timeout = 1800
########myiasm settings########
myisam_max_sort_file_size = 10G
myisam_sort_buffer_size = 128M
myisam_repair_threads = 1
myisam_recover_options=force,backup
########innodb settings########
innodb_buffer_pool_size = 8G
innodb_buffer_pool_instances = 4
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_data_file_path = ibdata1:1024M:autoextend
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_io_capacity = 1000
innodb_io_capacity_max = 2000
innodb_page_size = 8192
innodb_lru_scan_depth = 2000
innodb_lock_wait_timeout = 120
innodb_flush_method = O_DIRECT
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_log_group_home_dir = /data/mariadb-10.1/redolog
innodb_undo_directory = /data/mariadb-10.1/undolog
innodb_undo_logs = 128
innodb_undo_tablespaces = 3
innodb_flush_neighbors = 1
innodb_log_file_size = 512M
innodb_log_buffer_size = 16M
innodb_log_files_in_group = 2
innodb_purge_threads = 4
innodb_large_prefix = 1
innodb_thread_concurrency = 0
innodb_file_per_table = 1
innodb_print_all_deadlocks = 1
#innodb_strict_mode = 1
innodb_sort_buffer_size = 67108864
innodb_flush_log_at_trx_commit = 2
########log settings########
log_error = error.log
slow_query_log = 1
slow_query_log_file = slow.log
log_queries_not_using_indexes = 1
log_slow_admin_statements = 1
log_slow_slave_statements = 1
#log_throttle_queries_not_using_indexes = 10
expire_logs_days = 30
long_query_time = 2
min_examined_row_limit = 100
########replication settings########
server-id = 1
#master_info_repository = TABLE
#relay_log_info_repository = TABLE
log_bin = /data/mariadb-10.1/data/binlog
sync_binlog = 1
#gtid_mode = off
#enforce_gtid_consistency = 1
log_slave_updates
binlog_format = row
relay_log = relay.log
relay_log_recovery = 1
#binlog_gtid_simple_recovery = 1
#slave_skip_errors = ddl_exist_errors
slave_skip_errors = all
replicate_ignore_db = mysql
#replicate_do_db = 
relay_log_purge=0
########new settings########
sync_master_info = 1
binlog_checksum = CRC32
master_verify_checksum = 1
slave_sql_verify_checksum = 1
########semi sync replication settings########
#rpl_semi_sync_master_enabled = 1
#rpl_semi_sync_slave_enabled = 1
#rpl_semi_sync_master_timeout = 10000
[mysqldump]
quick
max_allowed_packet = 32M
[mysql]
no-auto-rehash
default-character-set = utf8
[myisamchk]
key_buffer_size = 128M
sort_buffer_size = 128M
read_buffer = 8M
write_buffer = 8M
[mysqlhotcopy]
interactive-timeout

EOF
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

if ! grep -q "mysql" /etc/passwd
then
    /usr/sbin/groupadd mysql
    /usr/sbin/useradd -g mysql mysql
else
    continue
fi

#if [ "`hostname`" != "$hostname" ]
#then
#hostnamectl set-hostname $hostname
#fi

if [ -d /data/mariadb-10.1 ]
then
    read -p "Mariadb path exists.delete? Y/N: " v
	if [ "$v" == "Y" ]
        then
		rm -rf /data/mariadb-10.1 && /bin/mkdir /data/mariadb-10.1/data -p
	else
	    exit 1
	fi
fi

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

read -p "Do you want use innodb options?(Y/N): " YN
if [ "$YN" == "Y" -o "$YN" == "y" ]
then
    setcnf
else
    cp support-files/my-large.cnf /etc/my.cnf
fi

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

cd /data/mariadb-10.1 && ./scripts/mysql_install_db --user=mysql --datadir=/data/mariadb-10.1/data
check_ok

systemctl enable mariadb.service
systemctl status mariadb.service

#cp support-files/mysql.server /etc/rc.d/init.d/mysqld && chmod 755 /etc/rc.d/init.d/mysqld
#chkconfig --add mysqld
#chkconfig  mysqld on

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

