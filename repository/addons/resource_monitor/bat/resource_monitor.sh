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
MONITOR_STATUS_QUE_CPU=${QUE_DIR}/monitor/${UNAME}_cpu_status
MONITOR_STATUS_QUE_MEMORY=${QUE_DIR}/monitor/${UNAME}_memory_status
MONITOR_STATUS_QUE_DISK=${QUE_DIR}/monitor/${UNAMAE}_${FILE_SYSTEM_NAME}_disk_status

## conf load
. ${SCRIPT_DIR}/monitor.conf


if [ ! -f ${CPU_LOG} ];then
 echo "time cpu_usage(%)" >  ${CPU_LOG}
fi

if [ ! -f ${MEMORY_LOG} ];then
 echo "time mem_usage(%)" >  ${MEMORY_LOG}
fi

## cpu resource get
IDLES=`vmstat 1 10 | awk '{print $15}' | grep -v id`
IDEL_USAGE=0
for idle in ${IDLES}
do
  IDEL_USAGE=`expr ${IDEL_USAGE} + ${idle}`
done

CPU_USAGE=`expr 1000 -  ${IDEL_USAGE}`
CPU_USAGE=`expr ${CPU_USAGE}  / 10`
CPU_USAGE=`echo ${CPU_USAGE} | awk -F"." '{print $1}'`
echo "`date +%T` ${CPU_USAGE}" >> ${CPU_LOG}


echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor SUCCESS cpu_usage_is_${CPU_USAGE}%" > ${MONITOR_STATUS_QUE_CPU}

## cpu resource check
if [ "${CPU_USAGE}" -ge "${CPU_WARN}" -a "${CPU_USAGE}" -lt "${CPU_CRIT}" ];then

  echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor WARN cpu_usage_is_${CPU_USAGE}%" > ${MONITOR_STATUS_QUE_CPU}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` WARN cpu usage is ${CPU_USAGE}%" >> ${MONITOR_ERROR_QUE}

  if [ ! -f ${SCRIPT_DIR}/.cpu_warn.tmp ];then

    touch ${SCRIPT_DIR}/.cpu_warn.tmp

  fi

else

 if [ -f ${SCRIPT_DIR}/.cpu_warn.tmp ];then
   rm ${SCRIPT_DIR}/.cpu_warn.tmp
 fi

fi

if [ "${CPU_USAGE}" -ge "${CPU_CRIT}" ];then

  echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor CRIT cpu_usage_is_${CPU_USAGE}%" > ${MONITOR_STATUS_QUE_CPU}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` CRIT cpu usage is ${CPU_USAGE} %" >> ${MONITOR_ERROR_QUE}

  if [ ! -f ${SCRIPT_DIR}/.cpu_crit.tmp ];then

    touch ${SCRIPT_DIR}/.cpu_crit.tmp

  fi

else

 if [ -f ${SCRIPT_DIR}/.cpu_crit.tmp ];then
   rm ${SCRIPT_DIR}/.cpu_crit.tmp
 fi

fi


## memory resource get
TOTAL=`free | grep Mem | awk '{print $2}'`
USED=`free | grep Mem | awk '{print $3}'`
MEMORY_USAGE=`expr ${USED} / ${TOTAL}`
MEMORY_USAGE=`expr ${MEMORY_USAGE} \* 100`
MEMORY_USAGE=`echo ${MEMORY_USAGE} | awk -F"." '{print $1}'`

echo "`date +%T` ${MEMORY_USAGE}" >> ${MEMORY_LOG}


echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor SUCCESS memory_usage_is_${MEMORY_USAGE}%" > ${MONITOR_STATUS_QUE_MEMORY}

## memory resource check
if [ "${MEMORY_USAGE}" -ge "${MEMORY_WARN}" -a "${MEMORY_USAGE}" -lt "${MEMORY_CRIT}" ];then

  echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor WARN memory_usage_is_${MEMORY_USAGE}%" > ${MONITOR_STATUS_QUE_MEMORY}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` WARN memory usage is ${MEMORY_USAGE} %" >> ${MONITOR_ERROR_QUE}

  if [ ! -f ${SCRIPT_DIR}/.memory_warn.tmp ];then

    touch ${SCRIPT_DIR}/.memory_warn.tmp

  fi

else

 if [ -f ${SCRIPT_DIR}/.memory_warn.tmp ];then
   rm ${SCRIPT_DIR}/.memory_warn.tmp
 fi

fi

if [ "${MEMORY_USAGE}" -ge "${MEMORY_CRIT}" ];then

  echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor CRIT memory_usage_is_${MEMORY_USAGE}%" > ${MONITOR_STATUS_QUE_MEMORY}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` CRIT memory usage is ${MEMORY_USAGE} %" >> ${MONITOR_ERROR_QUE}

  if [ ! -f ${SCRIPT_DIR}/.memory_crit.tmp ];then

    touch ${SCRIPT_DIR}/.memory_crit.tmp

  fi

else

 if [ -f ${SCRIPT_DIR}/.memory_crit.tmp ];then
   rm ${SCRIPT_DIR}/.memory_crit.tmp
 fi

fi


## disk usage
for FILE_SYSTEM in ` df -h | grep -v Filesystem | grep -v boot  | awk '{print $6}'`
do
  DISK_USAGE=`df -h ${FILE_SYSTEM} | grep -v Filesystem | awk '{print $5}'`
  echo "`date +%T` ${FILE_SYSTEM} ${DISK_USAGE}" >> ${DISK_USAGE_LOG}
  DISK_USAGE=`echo ${DISK_USAGE} | sed -e "s/%//g"`


  FILE_SYSTEM_NAME=`echo ${FILE_SYSTEM} | sed -e "s/\///g"`

  if [ "${FILE_SYSTEM_NAME}" = "" ];then
    FILE_SYSTEM_NAME="root"
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor SUCCESS ${FILE_SYSTEM}_usage_is_${DISK_USAGE}%" > ${MONITOR_STATUS_QUE_DISK}
  fi


  ## disk resource check
  if [ "${DISK_USAGE}" -ge "${DISK_WARN}" -a "${DISK_USAGE}" -lt "${DISK_CRIT}" ];then

    echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor WARN ${FILE_SYSTEM}_usage_is_${DISK_USAGE}%" > ${MONITOR_STATUS_QUE_DISK}
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` WARN ${FILE_SYSTEM} usage is ${DISK_USAGE}%" >> ${MONITOR_ERROR_QUE}

    if [ ! -f ${SCRIPT_DIR}/.disk_warn_${FILE_SYSTEM_NAME}.tmp ];then

      touch ${SCRIPT_DIR}/.disk_warn_${FILE_SYSTEM_NAME}.tmp

    fi

  else

   if [ -f ${SCRIPT_DIR}/.disk_warn_${FILE_SYSTEM_NAME}.tmp ];then
     rm ${SCRIPT_DIR}/.disk_warn_${FILE_SYSTEM_NAME}.tmp
   fi

  fi

  if [ "${DISK_USAGE}" -ge "${DISK_CRIT}" ];then

    echo "`date +%Y/%m/%d` `date +%H:%M:%S` addons resource_monitor CRIT ${FILE_SYSTEM}_usage_is_${DISK_USAGE}" > ${MONITOR_STATUS_QUE_DISK}
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` CRIT ${FILE_SYSTEM} usage is ${DISK_USAGE} %" >> ${MONITOR_ERROR_QUE}

    if [ ! -f ${SCRIPT_DIR}/.disk_crit_${FILE_SYSTEM_NAME}.tmp ];then

      touch ${SCRIPT_DIR}/.disk_crit_${FILE_SYSTEM_NAME}.tmp

    fi

  else

   if [ -f ${SCRIPT_DIR}/.disk_crit_${FILE_SYSTEM_NAME}.tmp ];then
     rm ${SCRIPT_DIR}/.disk_crit_${FILE_SYSTEM_NAME}.tmp
   fi

  fi

done

find ${SCRIPT_DIR} -type f -name *.tmp -mtime +0 |  xargs rm -f
exit 0
