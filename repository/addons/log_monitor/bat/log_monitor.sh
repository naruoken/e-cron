#!/bin/sh

## param setting
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
LOG_DIR=${SCRIPT_DIR}/../log
CPU_LOG=${LOG_DIR}/cpusage.log_`date +%Y%m%d`
MEMORY_LOG=${LOG_DIR}/memusage.log_`date +%Y%m%d`
DISK_USAGE_LOG=${LOG_DIR}/disk_usage.log_`date +%Y%m%d`
UNAME=`uname -n`
QUE_DIR=${SCRIPT_DIR}/../../../../que
MONITOR_ERROR_QUE=${QUE_DIR}/monitor/${UNAME}_error_`date +%Y%m%d`
TIME=`date +%s`
DETECTED_MESSAGES=${LOG_DIR}/detected_message_`date +%Y%m%d`
ERROR_TMP=${SCRIPT_DIR}/.error_tmp

if [ ! -f ${DETECTED_MESSAGES} ];then
  touch ${DETECTED_MESSAGES}
fi

## log check

cat ${SCRIPT_DIR}/monitor.conf | grep -v "^$" | grep -v ^#  > ${SCRIPT_DIR}/.monitor.conf.tmp
chmod 777 ${SCRIPT_DIR}/.monitor.conf.tmp

while read CONTEXT
do
  FULL_PATH=`echo $CONTEXT | awk -F"::" '{print $1}'`
  FILE_NAME=`echo $FULL_PATH | awk -F"/" '{print $NF}'`
  MESSAGE=`echo $CONTEXT | awk -F"::" '{print $2}'`
  MONITOR_STATUS_QUE=${QUE_DIR}/monitor/${UNAME}_${FILE_NAME}_status

  grep "${MESSAGE}" ${FULL_PATH} > ${ERROR_TMP}

  if [ $? = 0 ];then
    while read ERROR
    do

      grep "${ERROR}" ${DETECTED_MESSAGES}

      if [ $? != 0 ];then
        echo "`date +%Y/%m/%d` `date +%H:%M:%S` WARN_MESSAGE ${FULL_PATH}:${MESSAGE}" >> ${MONITOR_ERROR_QUE}
        SED_MESSAGE=`echo $MESSAGE | sed -e "s/ /_/"`
        echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons log_monitor WARN ${FULL_PATH}:${SED_MESSAGE}" > ${MONITOR_STATUS_QUE}
        echo "${ERROR}" >> ${DETECTED_MESSAGES}
      fi

    done < ${ERROR_TMP}
  fi
done < ${SCRIPT_DIR}/.monitor.conf.tmp

find ${SCRIPT_DIR} -type f -name *.tmp -mtime +0 |  xargs rm -f
