#!/bin/sh

#############################################
# snapshot script
#############################################
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`

## config load
. ${SCRIPT_DIR}/../.root
SNAP_SHOT=${ROOT}/log/snapshot/`date +%Y%m%d`

#get snapshot
sleep 1
SNAP=`ls ${ROOT}/que/tmp`
echo `date +%T` ${SNAP} >> ${SNAP_SHOT}

exit 0
