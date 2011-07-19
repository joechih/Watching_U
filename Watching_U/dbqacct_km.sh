#!/bin/sh 				
#  NAME									
#	dbqacct.sh - process LSF accounting file 	
#									
#  SYNOPSIS								
#	dbqacct.sh [YYYYMMDD [...]]					
#									
#  DESCRIPTION								
#	dbqacct.sh is the main daily accounting shell procedure.  It is	
#	normally initiated via cron.					
#									
#  FILES								
#	lsb.acct (accounting file from LSF)						
#									
#  AUTHOR								
#	Zhoujin Wu (ZjW)	< zjwu AT nchc DOT org DOT tw >		
#	Joe Chih ( joe@nchc.org.tw )								
#  REMARK								
#   1. This script should be run from cron (acctadm) at 1:30 AM does process	
#	accounting.  But also can be run manually to fix.		
#    							
#									
#  HISTORY								
#	pre 1.0	04/20/2004	(ZjW)					
#		...							
#	1.0	2008/08/08	(ZjW)					
#		Totally rewrite						
#	1.5 2011/06/27 (Joe Chih)
#  PLATFORM
#   KM CLUSTER LINUX								
#######################################################################

#######################################################################
#
#	Commands that be used in this script
#
GAWK=/usr/bin/gawk
INPUT=/hptc_cluster/lsf/work/hptclsf/logdir/lsb.acct
OUTPUT=/home/acctadm1/qdaily/
if [ 0 -eq $# ]
then
# The date of Today
yyyy=`date +%Y`
mm=`date +%m`
dd=`date +%d`
TDATE=`date +%Y%m%d`

# make "monthly" directory
monthly="${OUTPUT}/$yyyy/$mm"
if [ ! -d "$monthly" ]
then
	mkdir -p -m 0700 "$monthly"
fi

# The date of Yesterday
Yesterday=$(date -d "$Today a day ago" +%Y%m%d)
YYYY=$(echo $Yesterday | cut -b-4)
MM=$(echo $Yesterday | cut -b5,6)
DD=$(echo $Yesterday | cut -b7-)
YDATE=${YYYY}${MM}${DD}

# The output files
TEMP_FILE=${OUTPUT}/${YYYY}/${MM}/accounting
OUTPUT_FILE=${OUTPUT}/${YYYY}/${MM}/dbqacct.${YDATE}
OUTPUT_LOG=${OUTPUT}/${YYYY}/${MM}/dbqacct.log.${YDATE}

# Data processing
$GAWK '
BEGIN {
        type["\"serial\""] = "S"
		type["\"mono\""] = "P"
		type["\"xfer\""] = "P"
        type["\"4cpu\""] = "P"
        type["\"8cpu\""] = "P"
		type["\"16cpu\""] = "P"
		type["\"32cpu\""] = "P"
        type["\"48cpu\""] = "P"
		type["\"64cpu\""] = "P"
		type["\"128cpu\""] = "P"
        type["\"crystal\""] = "C"
        type["\"pcrystal\""] = "PC"
        type["\"freq\""] = "F"
        type["\"project\""] = "PJ"
        type["\"sc2003\""] = "SC"

}
$24 == 0 { next;}
$25 == 0 { next;}
$(NF-40) ~ "" {
	$(NF-40)="NA";
			}
#For KM Cluster LSF Queuing System
$2 ~ /"6.2"/ && $24  >=1 {
	FORMAT = "%Y%m%d"
	DATE = strftime(FORMAT, $3)
	FORMAT2 = "%Y/%m/%d %H/%M/%S"
	DATEE = strftime(FORMAT2, $3)
	DATES = strftime(FORMAT2, $8)
        if (DATE == "'${YDATE}'")
	print $4, $12, $13, "NA", DATES, DATEE, type[$13], $7, $(NF-16), $24, $11-$8, $3-$11, ($(NF-38)+$(NF-37)) / $24 , NF} ' $INPUT | sed s/\"//g | sed 's/\.\///' > $TEMP_FILE
# Basic on the TEMP_FILE, re-order the field value then output the data
	$GAWK '{
print $2":"$3":"$4":"$1":"$5, $6":"$7, $8":"$9":"$10":"$11":"$12":"$13":"$14":"$15
}' $TEMP_FILE > $OUTPUT_FILE
# Basic on the TEMP_FILE, declaration with BEGIN{},{do some caculation} then use END{} to output data 
	$GAWK 'BEGIN{
	Scount=0;
	Ssum=0;
	Pcount=0;
	Psum=0;}

$9 ~ "P" {
Pcount += 1;
Psum += $14*$12;}
$9 ~ "S" {
Scount += 1;
Ssum += $14*$12;}

END{print "'${YYYY}'/'${MM}'/'${DD}'"":"Scount":"Ssum":"Pcount":"Psum}' $TEMP_FILE > $OUTPUT_LOG

else
for d in $*
	do
		YYYY="`echo $d | cut -b-4`"
		MM="`echo $d | cut -b5,6`"
		DD="`echo $d | cut -b7-`"
		YDATE=${YYYY}${MM}${DD}
	done
# The output files
TEMP_FILE=${OUTPUT}/${YYYY}/${MM}/accounting
OUTPUT_FILE=${OUTPUT}/${YYYY}/${MM}/dbqacct.${YDATE}
OUTPUT_LOG=${OUTPUT}/${YYYY}/${MM}/dbqacct.log.${YDATE}

# Data processing
$GAWK '
BEGIN {
        type["\"serial\""] = "S"
		type["\"mono\""] = "P"
		type["\"xfer\""] = "P"
        type["\"4cpu\""] = "P"
        type["\"8cpu\""] = "P"
        type["\"16cpu\""] = "P"
		type["\"32cpu\""] = "P"
		type["\"48cpu\""] = "P"
		type["\"64cpu\""] = "P"
		type["\"128cpu\""] = "P"
        type["\"crystal\""] = "C"
        type["\"pcrystal\""] = "PC"
        type["\"freq\""] = "F"
        type["\"project\""] = "PJ"
        type["\"sc2003\""] = "SC"

}
$24 == 0 { next;}
$25 == 0 { next;}
#For Halen LSF Queuing System
$2 ~ /"6.2"/ && $24  >=1 {
	FORMAT = "%Y%m%d"
	DATE = strftime(FORMAT, $3)
	FORMAT2 = "%Y/%m/%d %H/%M/%S"
	DATEE = strftime(FORMAT2, $3)
	DATES = strftime(FORMAT2, $8)
        if (DATE == "'${YDATE}'")
	print $4, $12, $13, "NA", DATES, DATEE, type[$13], $7, $(NF-16), $24, $11-$8, $3-$11, ($(NF-38)+$(NF-37)) / $24 , NF} ' $INPUT | sed -e 's/\"//g' -e 's/\.\///' > $TEMP_FILE
# Basic on the TEMP_FILE, re-order the field value then output the data
	$GAWK '{
print $2":"$3":"$4":"$1":"$5, $6":"$7, $8":"$9":"$10":"$11":"$12":"$13":"$14":"$15
}' $TEMP_FILE > $OUTPUT_FILE
# Basic on the TEMP_FILE, declaration with BEGIN{},{do some caculation} then use END{} to output data 
	$GAWK 'BEGIN{
	Scount=0;
	Ssum=0;
	Pcount=0;
	Psum=0;}

$9 ~ "P" {
Pcount += 1;
Psum += $14*$12;}
$9 ~ "S" {
Scount += 1;
Ssum += $14*$12;}

END{print "'${YYYY}'/'${MM}'/'${DD}'"":"Scount":"Ssum":"Pcount":"Psum}' $TEMP_FILE > $OUTPUT_LOG
fi

exit 0
