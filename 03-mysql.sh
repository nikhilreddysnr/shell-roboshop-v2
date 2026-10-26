#!/bin/bash

source ./common.sh

dnf module enable mysql:8.4 -y &>>$log_File
dnf install mysql-server -y &>>$log_File
validate $? "$(timestamp) [INFO] Installing MySQL"

systemctl enable mysqld &>>$log_File
systemctl start mysqld &>>$log_File
validate $? "$(timestamp) [INFO] Starting MySQL"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "Setup MySQL Root Password"


total_time