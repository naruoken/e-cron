#!/bin/sh

#############################################
# e-cron daemon check script
#############################################

LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
LOG=${SCRIPT_DIR}/log/daedmon_check_`date +%Y%m%d`
UNAME=`uname -n`

# global.cof load
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
. ${SCRIPT_DIR}/../global.conf

ERROR_QUE=${ROOT}/que/daemon_error/${UNAME}_`date +%Y%m%d`

for DAEMON in ecron_mirrord ecron_messaged ecron_syslogd
do
  DAEMON_CHECK=`ps -ef | grep ${ROOT}/sbin/${DAEMON} | grep -v grep`

  if [ "${DAEMON_CHECK}" = "" ];then
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${DAEMON} don't running !! ${UNAME}" >> ${LOG}
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` ecron_daemon_check.sh: ${DAEMON} don't running !!" ${UNAME} >> ${ERROR_QUE}

    if [ -f /tmp/${DAEMON}_lock ];then
      rm /tmp/${DAEMON}_lock
    fi

    ${ROOT}/sbin/${DAEMON} &

    sleep 6

    DAEMON_CHECK=`ps -ef | grep ${ROOT}/sbin/${DAEMON} | grep -v grep`
    if [ "${DAEMON_CHECK}" = "" ];then
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${DAEMON} can't start !!" >> ${LOG}
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ecron_daemon_check.sh: ${DAEMON} can't start !! ${UAME}" >> ${ERROR_QUE}
    else
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${DAEMON} started" >> ${LOG}
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ecron_daemon_check.sh: ${DAEMON} started ${UAME}" >> ${ERROR_QUE}
   fi
 fi
done

exit 0
