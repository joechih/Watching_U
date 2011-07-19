#!/bin/sh
##################################################################
#
# NAME:        
#  get_daily_dbqacct.sh
#
# DESCRIPTION:     
#  get daily queuing system data from triton189
#
# USAGE:       
#  get_daily_dbqacct.sh [ ${YYYYMM} ]
#
# INPUT:       
#  copy queuing data from triton189:/home/acctadm1/qdaily/${YYYY}/${MM}/{dbqacct.${YDATE}, dbqacct.log.${YDATE}}
#
# OUPUT:      
#  /home/acctadm1/qdaily/${YYYY}/${MM}/{dbqacct.${YDATE}, dbqacct.log.${YDATE}}
#
# MODIFY DATE:        
#  2005.10.08
#
# REMARK:
#
# PLATFORM: 
#  KM Cluster nbumedia Linux
# AUTHOR:      
#  Yu I Chen (louie@nchc.org.tw), modify by Joe Chih
#
##################################################################


MKDIR=/bin/mkdir
CHOWN=/bin/chown
CHMOD=/bin/chmod
ECHO=/bin/echo
SCP=/usr/bin/scp
SSH=/usr/bin/ssh

if [ ! $USER == "acctadm" ]; then
        echo 'please run this script with user "acctadm"'
        exit 0
fi


if [ $1 ]; then
        YDATE=$1
else
        YDATE=`date -d "$Today a day ago" +%Y%m%d`
fi

# Define the variables
TDATE=`date +%Y%m%d`
yyyy=${TDATE:0:4}
mm=${TDATE:4:2}

YYYY=${YDATE:0:4}
MM=${YDATE:4:2}

Host=140.110.2.189
USER=acctadm
INPUT=/home/acctadm1/qdaily/
OUTPUT=/home/acctadm1/qdaily/
INPUT_FILES=${INPUT}/${YYYY}/${MM}/dbqacct.*${YDATE}

# make "monthly" directory
monthly="${OUTPUT}/$yyyy/$mm"
if [ ! -d "$monthly" ]
then
	mkdir -p -m 0700 "$monthly"
fi



# ssh acctadm@140.110.2.189:/home/acctadm1/qdaily/2011/07/dbqacct.*${YDATE}

$SCP -p $USER@$Host:${INPUT_FILES} ${OUTPUT}/${YYYY}/${MM}/


$ECHO "queuing data get successed !"

exit 0
