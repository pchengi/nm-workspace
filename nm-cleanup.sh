#!/bin/bash

rm -rf /esg
if [ "$1" = "full" ]; then
	yum remove postgresql-devel postgresql postgresql-server postgresql-libs
fi
