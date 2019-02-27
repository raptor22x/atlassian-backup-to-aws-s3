#!/bin/bash
#
# Author: Jose Villasenor
# Description:
#	Does a pg_dump --clean of the listed databases from postgres sql

## VARIABLES ##
databases="jira confluence stash crowd"
backupDir="/opt/backups"
dateformat=`date +%Y_%m_%d_Time_%H_%M`
homepath=$HOME
s3bucket="s3://S3_BUCKET_NAME/DB"
awsmv="aws s3 mv"
awsclitool=`which aws`
awsconfigfile="${homepath}/.aws/config"

## CHECKS AND BALANCES ##

# Checks aws tools are installed and configured#
if [ -z "${awsclitool}" ]
then
        echo -e "\n\nawscli tools not found, please make sure they are installed\n\n"
        exit
elif [ ! -s "${awsconfigfile}" ]
then
        echo -e "\n\nAWS config file seems to be missing, please populate with following information"
        echo -e "[default]\naws_access_key_id = USER ACCESS KEY ID HERE\naws_secret_access_key = USER SECRET ACCESS KEY HERE\nregion = us-west-1\noutput = json\n"
        echo -e "\nYou can also run \"aws configure\" under the account that will execute this script.\n The program will take care of writing the file.\n"
        exit
fi


#CHECK DIRECTORY EXIST
if [ ! -d ${backupDir} ]
then
	echo -e "\n\n### BACKUP Directory ${backupDir} does not exist\n\n"
	exit
fi


#CHECK FOR USER RUNNING THIS SCRIPT
# IT MUST BE RAN under postgres

if [ `whoami` != "postgres" ]
then
	echo -e "\n\n### Script needs to be ran under postgres user\nCurrently \`whoami\` is running this script\n\n"
	exit
fi

#RUN ACTUAL BACKUP PROGRAM
for dbname in ${databases};
do
	# Dump copy of database
	pg_dump --clean $dbname > ${backupDir}/$dbname-${dateformat}.sql
	# Move copy of database to S3 bucket DB folder.
	${awsmv} ${backupDir}/$dbname-${dateformat}.sql ${s3bucket}/
done

