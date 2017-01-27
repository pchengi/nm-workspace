#!/bin/bash

source ./setlocalpaths
yum -y install postgresql-devel postgresql postgresql-server postgresql-libs mod_ssl
pip install django==1.10.3
pip install sqlalchemy
pip install psycopg2
pip install requests
