#!/bin/sh

LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
JOBWRAPPER=`echo ${SCRIPT_DIR} | awk -F [/] '{field = $NF } END {print field }'`
REPOSITORY=`echo ${SCRIPT_DIR} | awk -F [/] '{field = $(NF-1) } END {print field}'`
SUDO_COMMAND="" #null

# .root load
. ${SCRIPT_DIR}/../../../.root

JOBWRAPPER_HOME=${SCRIPT_DIR}
JOBWRAPPER_LOG=${ROOT}/log/${JOBWRAPPER}_log_`date +%Y%m%d`
COMMAND_DUMP=${ROOT}/log/${JOBWRAPPER}_command_dump_`date +%Y%m%d`
STATUS_QUE=${ROOT}/que/status/${REPOSITORY}_${JOBWRAPPER}
ERROR_QUE=${ROOT}/que/error/${JOBWRAPPER}_`date +%s`
TMP_QUE=${ROOT}/que/tmp/${REPOSITORY}::${JOBWRAPPER}


## jobwrapper prof load
grep -v SCHEDULE ${SCRIPT_DIR}/jobwrapper.prof > ${SCRIPT_DIR}/.jobwrapper_tmp
chmod 766 ${SCRIPT_DIR}/.jobwrapper_tmp
. ${SCRIPT_DIR}/.jobwrapper_tmp

STATUS_QUE_INPUT_MESSAGE=${ROOT}/que/status/${REPOSITORY}_${JOBWRAPPER}_IN_MESSAGE
STATUS_QUE_OUTPUT_MESSAGE=${ROOT}/que/status/${REPOSITORY}_${JOBWRAPPER}_OUT_MESSAGE

if [ "${JOB_EXEC_USER}" = "" ];then
  JOB_EXEC_USER=ejobmgr
fi

# double start check
OLDEST=$(pgrep -fo $0)
if [ $$ != $OLDEST ] && [ $PPID != $OLDEST ]; then
  WARN_FLAG=JOBWRAPPER_TRIED_TO_DOUBLE_START
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` WARNING ${WARN_FLAG}" >> ${JOBWRAPPER_LOG}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} WARN ${WARN_FLAG}" >> ${ERROR_QUE}
  exit 1
fi


#jobwrapper start
touch ${STATUS_QUE}


if [ "${JOB_EXEC_USER}" != ejobmgr ];then
  SUDO_COMMAND="sudo su ${JOB_EXEC_USER} -c"
fi



## mesage check
count=0
sleep_time=10
if [ "${INPUT_MESSAGE}" ];then
 for MESSAGE in ${INPUT_MESSAGE}
 do
   message_check=no
   while [ "$message_check" = "no" ]; do
     if [ ! -f "${ROOT}/que/message/${MESSAGE}" ]; then
       echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} INFO input_message_${MESSAGE}_not_set" > ${STATUS_QUE_INPUT_MESSAGE}
       sleep 10
       count=`expr ${count} + 1`
       sleep_time=`expr ${count} \* 10`

       if [ "${count}" = 360 ];then
         ERROR_FLAG=MESSAGE_CHECK_OVER_RETRY_COUNT
         echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} ERROR input_message_${MESSAGE}_was_not_set_by_${sleep_time}_sec" > ${STATUS_QUE_INPUT_MES
SAGE}
         echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} ERROR ${ERROR_FLAG}" >> ${ERROR_QUE}
         exit 1
       fi
     else
       message_check=yes
     fi
   done
 done

 echo "`date +%Y/%m/%d` `date +%H:%M:%S` input message ${INPUT_MESSAGE} confirmed" >> ${JOBWRAPPER_LOG}
 echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} INFO input_message_${INPUT_MESSAGE}_confirmed" > ${STATUS_QUE_INPUT_MESSAGE}

fi

## command exexute

touch ${TMP_QUE}
ERROR_FLAG=""


# Start JOB
echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${EXECUTE_COMMAND} EXECUTED"   >> ${COMMAND_DUMP}
echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} SUCCESS STARTED(RUNNING) " > ${STATUS_QUE}
echo "`date +%Y/%m/%d` `date +%H:%M:%S` EXEC ${EXECUTE_COMMAND} " >> ${JOBWRAPPER_LOG}

if [ "${JOB_EXEC_USER}" = ejobmgr ];then
  ${EXECUTE_COMMAND}  >> ${COMMAND_DUMP} 2>&1
else
  ${SUDO_COMMAND} ${EXECUTE_COMMAND}  >> ${COMMAND_DUMP} 2>&1
fi

EXECUTE_COMMAND_CHECK=$?

if [ "${EXECUTE_COMMAND_CHECK}" != 0 ];then
  ERROR_FLAG=EXECUTE_COMMAND_FAILED
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` ERROR ${ERROR_FLAG} " >> ${JOBWRAPPER_LOG}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} ERROR ${ERROR_FLAG}" > ${STATUS_QUE}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} ERROR ${ERROR_FLAG} " >> ${ERROR_QUE}

  if [ "${RECOVERY_COMMAND}" ];then
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} WARN RECOVERY_STARTED" > ${STATUS_QUE}
    echo "`date +%Y/%m/%d` `date +%H:%M:%S` EXEC ${RECOVERY_COMMAND} " >> ${COMMAND_DUMP}

    if [ "${JOB_EXEC_USER}" = ejobmgr ];then
      ${RECOVERY_COMMAND} >> ${COMMAND_DUMP} 2>&1
    else
      ${SUDO_COMMAND} ${RECOVERY_COMMAND} >> ${COMMAND_DUMP} 2>&1
    fi

    RECOVERY_COMMAND_CHECK=$? >> ${COMMAND_DUMP} 2>&1

    if [ "${RECOVERY_COMMAND_CHECK}" != 0 ];then
      ERROR_FLAG=RECOVERY_FAILED
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} ERROR ${ERROR_FLAG} " > ${STATUS_QUE}
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${JOB} ERROR ${ERROR_FLAG} " >> ${JOBWRAPPER_LOG}
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} ${ERROR_FLAG} " >> ${ERROR_QUE}

    else
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} INFO RECOVERY_COMPLETED " > ${STATUS_QUE}
      echo "`date +%Y/%m/%d` `date +%H:%M:%S` RECOVERY COMPLETED" >> ${JOBWRAPPER_LOG}
       
    fi
     
    rm -f ${TMP_QUE}
    exit 1   
     
  fi
   
 else

  echo "`date +%Y/%m/%d` `date +%H:%M:%S` SUCCESS COMPLETED"   >> ${JOBWRAPPER_LOG}
  echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} SUCCESS COMPLETED" > ${STATUS_QUE}
  rm -f ${TMP_QUE}

 fi


# Create output message
if [ "${OUTPUT_MESSAGE}" ];then
   if [ -f "${ROOT}/que/message/${OUTPUT_MESSAGE}" ]; then
     echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} WARN output_message_${OUTPUT_MESSAGE} is duplicated" > ${STATUS_QUE_OUTPUT_MESSAGE}
   else
     touch ${ROOT}/que/message/${OUTPUT_MESSAGE}
     echo "`date +%Y/%m/%d` `date +%H:%M:%S` ${REPOSITORY} ${JOBWRAPPER} INFO output_message_${OUTPUT_MESSAGE}_generated" > ${STATUS_QUE_OUTPUT_MESSAGE}
     echo "`date +%Y/%m/%d` `date +%H:%M:%S` output message ${OUTPUT_MESSAGE} generated" >> ${JOBWRAPPER_LOG}
   fi
fi

# Remove input message
if [ "${INPUT_MESSAGE}" ];then
  for MESSAGE in ${INPUT_MESSAGE}
  do
   rm -f ${ROOT}/que/message/${MESSAGE}
  done
fi
