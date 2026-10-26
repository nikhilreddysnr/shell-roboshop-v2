#!/bin/bash

source ./common.sh

chech_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding Mongo Repo"

dnf install mongodb-org -y &>>$log_File
validate $? "Installing Mongo DB"

systemctl enable mongod &>>$log_File
systemctl start mongod &>>$log_File
validate $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validate $? "Updating Mongo Conf to AnyIP"

systemctl restart mongod
validate $? "Restarting MongoDB"

total_time