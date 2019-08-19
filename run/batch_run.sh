#!/usr/bin/env bash

declare -i COUNT=$1-1

echo startinng 0 to n0.nohup
nohup ./runFast.sh p0.ora > n0.nohup 2>&1 &
for i in $(seq 1 $COUNT)
do
echo starting $i \(fast\) to n$i.nohup
nohup ./runFast.sh p$i.ora > n$i.nohup 2>&1 &
done
