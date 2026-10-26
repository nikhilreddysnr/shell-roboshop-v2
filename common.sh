#!/bin/bash

logs_Folder="/var/log/shell-practice"
log_File="${logs_Folder}/${0}.log"
userId=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root()
{
    if [ $userId -ne 0 ]; then
    echo "Please execute this command with root user or sudo"
    exit 1
    fi
}


mkdir -p $logs_Folder

validate()
{
    if [ $1 -ne 0 ]; then
        echo "$(timestamp) [ERROR] $2 Failed" | tee -a $log_File
        exit 1
    else
        echo "$(timestamp) [INFO] $2 Success" | tee -a $log_File
    fi
}

timestamp()
{
    date "+%F %T"
}

echo "$(timestamp) [INFO] =======Script Started Execution=========" | tee -a $log_File

total_time()
{
    echo "$(timestamp) [INFO] Script completed in $SECONDS seconds" | tee -a $log_File
    echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $log_File
}
