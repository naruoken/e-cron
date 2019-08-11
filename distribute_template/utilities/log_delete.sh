#!/bin/sh

#############################################
# log delete script
#############################################
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
LOG=${SCRIPT_DIR}/log/delete_jobnet_log_`date +%Y%m%d`

## root dir load
. ${SCRIPT_DIR}/../.root

#jobnetlog
for REPOSITORY in `ls ${ROOT}/repository`
do
  for JOBWRAPPER in `ls  ${ROOT}/repository/${REPOSITORY}`
  do 
   find ${ROOT}/repository/${REPOSITORY}/${JOBWRAPPER}/log -type f -mtime +90 >> ${LOG} 2>&1
   find ${ROOT}/repository/${REPOSITORY}/${JOBWRAPPER}/log -type f -mtime +90 | xargs rm -f  >> ${LOG} 2>&1
  done
done

#script log
find ${SCRIPT_DIR}/log -type f -mtime +7 >> ${LOG} 2>&1
find ${SCRIPT_DIR}/log -type f -mtime +7 | xargs rm -f  >> ${LOG} 2>&1

#snapshot
find ${ROOT}/snapshot -type f -mtime +30 >> ${LOG} 2>&1
find ${ROOT}/snapshot -type f -mtime +30 | xargs rm -f  >> ${LOG} 2>&1

exit 0
