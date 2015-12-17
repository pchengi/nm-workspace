#!/bin/bash

source ./setlocalpaths
yum -y install postgresql-devel postgresql postgresql-server postgresql-libs
pip install django==1.8.3
pip install sqlalchemy
pip install psycopg2

