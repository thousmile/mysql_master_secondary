vim [master.sh](mysql8_master/init/master.sh)

```shell
#!/bin/bash

MASTER_SYNC_USER=${MASTER_SYNC_USER:-sync_admin}
MASTER_SYNC_PASSWORD=${MASTER_SYNC_PASSWORD:-sync_admin123456}
MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin123456}
ALLOW_HOST=${ALLOW_HOST:-%}

CREATE_USER_SQL="CREATE USER '$MASTER_SYNC_USER'@'$ALLOW_HOST' IDENTIFIED BY '$MASTER_SYNC_PASSWORD';"
GRANT_PRIVILEGES_SQL="GRANT REPLICATION SLAVE,REPLICATION CLIENT ON *.* TO '$MASTER_SYNC_USER'@'$ALLOW_HOST';"
FLUSH_PRIVILEGES_SQL="FLUSH PRIVILEGES;"

mysql -u"$MYSQL_ROOT_USER" -p"$ADMIN_PASSWORD" -e "$CREATE_USER_SQL"
mysql -u"$MYSQL_ROOT_USER" -p"$ADMIN_PASSWORD" -e "$GRANT_PRIVILEGES_SQL"
mysql -u"$MYSQL_ROOT_USER" -p"$ADMIN_PASSWORD" -e "$FLUSH_PRIVILEGES_SQL"
```

vim [slave.sh](mysql8_slave/init/slave.sh)
```shell
#!/bin/bash

SLAVE_SYNC_USER="${MASTER_SYNC_USER:-sync_admin}"
SLAVE_SYNC_PASSWORD="${MASTER_SYNC_PASSWORD:-sync_admin123456}"
MYSQL_ROOT_USER="${MYSQL_ROOT_USER:-root}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin123456}"
MASTER_HOST="${MASTER_HOST:-%}"
MASTER_PORT="${MASTER_PORT:-%}"

sleep 10

RESULT=`mysql -h$MASTER_HOST -p$MASTER_PORT -u"$SLAVE_SYNC_USER" -p"$SLAVE_SYNC_PASSWORD" -e "SHOW MASTER STATUS;" | grep -v grep |tail -n +2| awk '{print $1,$2}'`
LOG_FILE_NAME=`echo $RESULT | grep -v grep | awk '{print $1}'`
LOG_FILE_POS=`echo $RESULT | grep -v grep | awk '{print $2}'`

SYNC_SQL="change master to master_host='$MASTER_HOST', master_port=$MASTER_PORT, master_user='$SLAVE_SYNC_USER',master_password='$SLAVE_SYNC_PASSWORD',master_log_file='$LOG_FILE_NAME',master_log_pos=$LOG_FILE_POS;"
START_SYNC_SQL="start slave;"
STATUS_SQL="show slave status\G;"

mysql -u"$MYSQL_ROOT_USER" -p"$ADMIN_PASSWORD" -e "$SYNC_SQL"
mysql -u"$MYSQL_ROOT_USER" -p"$ADMIN_PASSWORD" -e "$START_SYNC_SQL"
mysql -u"$MYSQL_ROOT_USER" -p"$ADMIN_PASSWORD" -e "$STATUS_SQL"
```


```shell

docker compose up -d

```

```sql
SELECT `Host`,`User` FROM mysql.`user`


SHOW MASTER STATUS;


SHOW SLAVE STATUS;


SHOW VARIABLES;


SHOW VARIABLES LIKE '%collation%';

```