#!/bin/sh

#############################################
# que delete script
#############################################
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
LOG=${SCRIPT_DIR}/log/delete_que_`date +%Y%m%d`

## .root load
. ${SCRIPT_DIR}/../.root

QUE_DIR=${ROOT}/que

#status que
find ${QUE_DIR}/status -type f -mtime +4 >> ${LOG} 2>&1
find ${QUE_DIR}/status -type f -mtime +4 | xargs rm -f  >> ${LOG} 2>&1

#error que
find ${QUE_DIR}/error -type f -mtime +30 >> ${LOG} 2>&1
find ${QUE_DIR}/error -type f -mtime +30 | xargs rm -f  >> ${LOG} 2>&1

#monitor que
find ${QUE_DIR}/monitor -type f -mtime +30 >> ${LOG} 2>&1
find ${QUE_DIR}/monitor -type f -mtime +30 | xargs rm -f  >> ${LOG} 2>&1

exit 0
