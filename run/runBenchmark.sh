#!/usr/bin/env bash

if [ $# -ne 1 ] ; then
    echo "usage: $(basename $0) PROPS_FILE" >&2
    exit 2
fi

SEQ_FILE="./.jTPCC_run_seq.dat"
if [ ! -f "${SEQ_FILE}" ] ; then
    echo "0" > "${SEQ_FILE}"
fi
SEQ=$(expr $(cat "${SEQ_FILE}") + 1) || exit 1
echo "${SEQ}" > "${SEQ_FILE}"

source funcs.sh $1

setCP || exit 1

myOPTS="-Dprop=$1 -DrunID=${SEQ}"

# only standalone html is needed
rm -r -f *log
./runSQL.sh "$1" prepare
echo BEGIN: $(date) >> benchmark.run
./runSQL.sh "$1" snapshot
java -cp "$myCP" $myOPTS jTPCC
echo END: $(date) >> benchmark.run
./runSQL.sh "$1" snapshot
