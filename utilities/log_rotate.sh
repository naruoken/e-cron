#!/bin/sh

#############################################
# daemon log rotate script
#############################################

## global.cof load
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
. ${SCRIPT_DIR}/../global.conf

## parameter setting
LOG_DIR=${ROOT}/log
MAX_SIZE=1000000
MAX_TERM=90
ROTATE_LOG=${ROOT}/utilities/log/daemon_log_rotate_`date +%Y%m%d`
DEL_LOG=${ROOT}/utilities/log/daemon_log_delete_`date +%Y%m%d`

for LOG in `ls ${LOG_DIR}/*.log`
do
  LOG_SIZE=`ls -l ${LOG} | awk '{print $5}'`

  if [ ${LOG_SIZE} -ge ${MAX_SIZE} ];then
    gzip ${LOG}    
    mv ${LOG}.gz ${LOG}_`date +%Y%m%d`.gz
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${LOG}_`date +%Y%m%d`.gz compressed" >> ${ROTATE_LOG}
  fi
done

find ${LOG_DIR}/*gz -type f -mtime +${MAX_TERM} | xargs rm -f  >> ${DEL_LOG} 2>&1


exit 0
