# atlassian-backup-to-aws-s3
Two backup scripts that simplify the backups of Atlassian data and Databases:

- atlassian_FS_backup.sh: Script takes in parameter of product name, creates a tar file and copies it to the S3 bucket.

example: ./atlassian_FS_backups.sh jira   


- DB_backup.sh: Creates a sql dump of the database.


##########
For either script, please review and update the necessary values specially the S3 bucket name and/or the application-data folder path 
