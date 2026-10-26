#!/bin/bash

source ./common.sh

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$log_File
validate $? "Adding RabbitMQ Repo"

dnf install erlang rabbitmq-server -y &>>$log_File
validate $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>>$log_File
systemctl start rabbitmq-server &>>$log_File
validate $? "ENabling And Starting Rabbit MQ"

rabbitmqctl list_users | grep -qw "roboshop" &>>$log_File
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>$log_File
    validate $? "Creating RabbitMQ user for Roboshop"    
else
    echo -e "$(timestamp) [INFO] RabbitMQ user already exist...${Y}SKIPPING${N}" 
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_File
validate $? "Setting permissions for RabbitMQ user for Roboshop"

total_time