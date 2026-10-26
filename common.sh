#!/bin/bash

logs_Folder="/var/log/shell-practice"
log_File="${logs_Folder}/${0}.log"
userId=$(id -u)
script_dir=$( dirname "$(realpath "${0}")")
domain_name=nikhil92s.store

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

java_setup()
{
    dnf module enable maven:3.9 -y &>>$log_File
    dnf install maven java-25-openjdk-devel -y &>>$log_File
    validate $? "Installing Java"

    alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
    validate $? "Setting Java 25 as default Java version"


    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo $JAVA_HOME
    validate $? "Setting JAVA_HOME for Maven"

    cd /app
    mvn clean package &>>$log_File
    validate $? "Installing Dependencies"

    mv target/shipping.jar shipping.jar
    validate $? "Moving SHipping.jar file"

}

nodejs_setup()
{
    dnf module disable nodejs -y &>>$log_File
    dnf module enable nodejs:24 -y &>>$log_File
    dnf install nodejs -y &>>$log_File
    validate $? "Installing NodeJs"

    cd /app
    npm install &>>$log_File
    validate $? "Installing Dependencies"
}

app_setup()
{
    id roboshop &>>$log_File
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_File
        validate $? "Creating system user"
    else
        echo "$(timestamp) [INFO] Roboshop User already Exist... ${Y}Skipping${N}"
    fi

    rm -rf /app
    validate $? "Removing Old Code"

    mkdir -p /app
    validate $? "Creating App Directory"


    curl -L -o /tmp/$app_name.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip &>>$log_File
    validate $? "Downloading $app_name Application"


    cd /app
    unzip /tmp/$app_name.zip &>>$log_File
    validate $? "Unzipping $app_name Application"


    sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir"/$app_name.service
    validate $? "Updating Domain Names in $app_name.service"

    cp "$script_dir"/$app_name.service /etc/systemd/system/$app_name.service 
    validate $? "Copying $app_name Service"
}

systemd_start()
{
    systemctl daemon-reload &>>$log_File
    systemctl enable $app_name &>>$log_File
    systemctl start $app_name &>>$log_File
    validate $? "Starting $app_name"
}

systemd_restart()
{
    systemctl restart $app_name &>>$log_File
    validate $? "Restarting $app_name"
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
