#!/bin/bash


git pull
source ./setlocalpaths

pushd  /root/esgf-nodemgr-doc/code
git pull
#bash run_server.sh
service nm-httpd start
#/usr/local/bin/esgf-nm-ctl start
popd

