```shell

mkdir $PWD/mysql8_master/{conf,data} && mkdir $PWD/mysql8_slave1/{conf,data} && mkdir $PWD/mysql8_slave2/{conf,data} && mkdir $PWD/proxysql/data

chmod 777 -R *

docker compose up -d

docker exec -it proxysql /bin/bash

mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin>'

```

```sql

SET mysql-eventslog_filename='queries.log';

INSERT INTO mysql_servers (hostgroup_id, hostname, PORT, COMMENT)
VALUES (10, 'mysql8_master', 3306, "mysql8_master"),
       (20, 'mysql8_slave1', 3306, "mysql8_slave1"),
       (20, 'mysql8_slave2', 3306, "mysql8_slave2");

INSERT INTO mysql_users (username, PASSWORD, default_hostgroup, transaction_persistent)
VALUES ('proxysql', 'proxysql_123456', 10, 1),
       ('test', 'test_123456', 10, 1);

set mysql-monitor_username='proxysql_monitor';
set mysql-monitor_password='proxysql_monitor_123456';

INSERT INTO mysql_query_rules ( rule_id, active, match_pattern, destination_hostgroup, apply )
VALUES
    ( 1, 1, '^select.*for update$', 10, 1 ),
    ( 2, 1, '^select', 20, 1 );

load mysql users to runtime;
load mysql servers to runtime;
load mysql query rules to runtime;
load mysql variables to runtime;
load admin variables to runtime;

save mysql users to disk;
save mysql servers to disk;
save mysql query rules to disk;
save mysql variables to disk;
save admin variables to disk;

```
