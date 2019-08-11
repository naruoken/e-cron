#!/bin/sh

#############################################
# que delete script
#############################################

# global.cof load
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
. ${SCRIPT_DIR}/../global.conf

LOG=${SCRIPT_DIR}/log/delete_que_`date +%Y%m%d`

QUE_DIR=${ROOT}/que

#daemon_error que
find ${QUE_DIR}/daemon_error -type f -mtime +30 >> ${LOG} 2>&1
find ${QUE_DIR}/daemon_error -type f -mtime +30 | xargs rm -f  >> ${LOG} 2>&1

#daemon_status que
find ${QUE_DIR}/endpoint_status -type f -mtime +30 >> ${LOG} 2>&1
find ${QUE_DIR}/endpoint_status -type f -mtime +30 | xargs rm -f  >> ${LOG} 2>&1

#message que
find ${QUE_DIR}/send_message -type f -mtime +30 >> ${LOG} 2>&1
find ${QUE_DIR}/send_message -type f -mtime +30 | xargs rm -f  >> ${LOG} 2>&1

exit 0
