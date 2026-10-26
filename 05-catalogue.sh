#!/bin/bash
app_name=catalogue
source ./common.sh


check_root

app_setup

nodejs_setup


systemd_start


cp "$script_dir"/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding Mongo Repo"

dnf install mongodb-mongosh -y &>>$log_File
validate $? "Installing MongoDB Client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>>$log_File)
validate $? "Connecting to Mongo DB"

if [ $product_count -eq 0 ]; then
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>>$log_File
    validate $? "Loading Products"
else
    echo -e "$(timestamp) [INFO] Products already loaded...${Y}Skipping${N}"
fi


systemd_restart

total_time