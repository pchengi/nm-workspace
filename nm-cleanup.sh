#!/bin/bash

have_esgf=0
if [ $have_esgf -eq 0 ]; then
	rm -rf /esg
	if [ "$1" = "full" ]; then
		yum remove postgresql-devel postgresql postgresql-server postgresql-libs
	fi
else
	rm -rf /esg/tasks
	rm -f /esg/config/esgf_nodemgr_map.json
	rm -f /esg/config/nm.properties
fi
