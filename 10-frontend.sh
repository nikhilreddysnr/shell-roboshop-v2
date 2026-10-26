#!/bin/bash

source ./common.sh

check_root
dnf module disable nginx -y &>>$log_File
dnf module enable nginx:1.26 -y &>>$log_File
dnf install nginx -y &>>$log_File
validate $? "Installing NGINX"


systemctl enable nginx &>>$log_File
systemctl start nginx &>>$log_File
validate $? "Starting NGINX"

rm -rf /usr/share/nginx/html/* &>>$log_File
validate $? "Removing default Content"



curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>>$log_File
cd /usr/share/nginx/html &>>$log_File
unzip /tmp/frontend.zip &>>$log_File
validate $? "Downloading and UnZipping Frontend Code"


sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir"/roboshop.conf
validate $? "Updating all Domain Name"

cp "$script_dir"/roboshop.conf /etc/nginx/default.d/roboshop.conf
validate $? "Copying Configuration"

nginx -t &>> $log_File
validate $? "Nginx Configuration"

systemctl restart nginx &>>$log_File
validate $? "Restarting Frontend"


total_time