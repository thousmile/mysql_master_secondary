#!/bin/bash

SLAVE_SYNC_USER="${MASTER_SYNC_USER:-sync_user}"
SLAVE_SYNC_PASSWORD="${MASTER_SYNC_PASSWORD:-sync_user_123456}"
MYSQL_ROOT_USER="${MYSQL_ROOT_USER:-root}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root123456}"
MASTER_HOST="${MASTER_HOST:-%}"
MASTER_PORT="${MASTER_PORT:-%}"

sleep 10

RESULT=`mysql -h$MASTER_HOST -p$MASTER_PORT -u"$SLAVE_SYNC_USER" -p"$SLAVE_SYNC_PASSWORD" -e "SHOW MASTER STATUS;" | grep -v grep |tail -n +2| awk '{print $1,$2}'`
LOG_FILE_NAME=`echo $RESULT | grep -v grep | awk '{print $1}'`
LOG_FILE_POS=`echo $RESULT | grep -v grep | awk '{print $2}'`

SYNC_SQL="change master to master_host='$MASTER_HOST', master_port=$MASTER_PORT, master_user='$SLAVE_SYNC_USER',master_password='$SLAVE_SYNC_PASSWORD',master_log_file='$LOG_FILE_NAME',master_log_pos=$LOG_FILE_POS;"
START_SYNC_SQL="start slave;"
STATUS_SQL="show slave status\G;"

mysql -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "$SYNC_SQL"
mysql -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "$START_SYNC_SQL"
mysql -u"$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" -e "$STATUS_SQL"