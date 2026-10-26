#!/bin/bash

app_name=payment
source ./common.sh



check_root

app_setup

python_setup


systemd_start

systemd_restart


total_time