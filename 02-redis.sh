#!/bin/bash

source ./common.sh

check_root

dnf module disable redis -y &>>$log_File
dnf module enable redis:7 -y &>>$log_File
dnf install redis -y &>>$log_File

validate $? "$(timestamp) [INFO] $(timestamp) Installing Redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

validate $? "$(timestamp) [INFO] Updating Redis Conf"

systemctl enable redis &>>$log_File
systemctl start redis &>>$log_File
validate $? "$(timestamp) [INFO] Starting Redis"

total_time