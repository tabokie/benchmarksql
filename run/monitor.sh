#!/usr/bin/env bash

if [ $# -ne 2 ] ; then
    echo "usage: $(basename $0) DURATION(min) TICK(sec)" >&2
    exit 2
fi
 
DURATION=$1
TICK=$2

declare -i COUNT=$DURATION*60/$TICK

echo BEGIN: $(date) >> monitor.log
./runSQL.sh props.ora snapshot
nohup iostat -x $TICK $COUNT > iostat.log &
top -n $COUNT -d $TICK -b > top.log

./runSQL.sh props.ora snapshot
echo END: $(date) >> monitor.log
