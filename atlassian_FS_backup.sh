#!/bin/bash

#######################
# Author: Jose Villasenor
#
# Description: 	Backup the local files system of atlassian products.
#		
#
#######################


## Variables ##
projectName="$1"
backupDirectory="/opt/backups"
dateformat=`date +%Y_%m_%d_Time_%H_%M`
homepath=$HOME
s3bucket="s3://S3_BUCKET_NAME"
awsmv="aws s3 mv"
awsclitool=`which aws`
awsconfigfile="${homepath}/.aws/config"

# Function to display usage message and exit #
function use_msg_exit(){
	echo " "
	echo -e "Please provide a project name: jira, confluence, or stash\n"
 	echo -e "Usage: $0 <Project Name>\n\n"
	exit
}


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

# Check to make sure  variable is not empty #
if [ -z "$projectName" ]
then
	use_msg_exit
fi

# Convert string to lowercase #
projectNameLowercase=`echo "$projectName" | tr "[A-Z]" "[a-z]"`


# Check if projects are within atlassian product line #
## Dynamic variables ##
case $projectNameLowercase in
	"jira"|"confluence")
		SourceDirectory="/var/atlassian/application-data/$projectNameLowercase"
		;;
	"stash"|"bitbucket")
		projectNameLowercase="stash"
		SourceDirectory="/opt/repos"
		;;
	*)
		use_msg_exit
		;;
esac
				

## CHECK DIRECTORIES EXIST ##

if [ ! -d $backupDirectory ]
then
        echo -e "\n::Backup directory is missing::\nPlease make sure $backupDirectory exist\n\n"
        exit
fi

if [ ! -d $SourceDirectory ]
then
        echo -e "\n::Source directory is missing::\nPlease make sure $SourceDirectory exist\n\n"
        exit
fi


## Functions ##

# --Create Tar file of source directory
function create_tar() {
	tar -czpf $backupDirectory/$projectNameLowercase-$dateformat.tgz $SourceDirectory
}

# -- Uploads the created backup gzipped tar archive to the S3 bucket. This is using move function.
function awsupload(){
	${awsmv} $backupDirectory/$projectNameLowercase-$dateformat.tgz $s3bucket/$projectNameLowercase/
}


## RUN PROGRAM ##
create_tar
awsupload
