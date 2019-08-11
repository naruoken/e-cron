#!/bin/sh

#############################################
# utility log delete script
#############################################

## global.cof load
LANG=C;export LANG
SCRIPT_DIR=`dirname $0`
. ${SCRIPT_DIR}/../global.conf

find ${SCRIPT_DIR}/log -type f -mtime +90 | xargs rm -f 2>&1

exit 0
