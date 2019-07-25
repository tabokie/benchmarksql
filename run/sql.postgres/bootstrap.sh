#!/usr/bin/env bash
PG_DATA=/data/1/tpcc/postgres
PG_WAL=/data/log1/postgres.xinye.txy
LOG=/home/xinye.txy/postgres.log
CONF=/home/xinye.txy/benchmarksql/run/sql.postgres/postgresql.conf
pg_ctl -D $PG_DATA -l $LOG stop
rm -rf $PG_DATA
rm -rf $PG_WAL
mkdir -p $PG_DATA
mkdir -p $PG_WAL
# ln -s $PG_DATA/pg_wal $PG_WAL
initdb -D $PG_DATA -X $PG_WAL -U xinye.txy -E SQL_ASCII --locale=C
cat $CONF >> $PG_DATA/postgresql.auto.conf
pg_ctl -D $PG_DATA -l $LOG start
createdb postgres
# createuser bmsql -P -s