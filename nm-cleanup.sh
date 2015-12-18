#!/bin/bash

if env|grep NO_ESGF >/dev/null; then
	if [ $NO_ESGF -eq 1 ]; then
		echo "Explicitly set to NO ESGF";
		rm -rf /esg
		if [ "$1" = "full" ]; then
			yum -y remove postgresql-devel postgresql postgresql-server postgresql-libs
			rm -rf /etc/tempcerts
			rm -rf /etc/certs
			rm -f /etc/httpd/conf/nm-httpd.conf
			rm -f /etc/init.d/nm-httpd
			rm -rf /opt/esgf
			rm -f /usr/local/bin/esgf-nm-ctl
			rm -rf /usr/local/esgf-nodemgr-doc
			rm -f /esg/log/esgf_nm.log
			rm -f /esg/log/esgf_nm_dj.log
			rm -f /esg/log/django.log
		fi
	fi
else
	echo "There IS ESGF. Tread with care.";
	rm -rf /esg/tasks
	rm -f /esg/config/esgf_nodemgr_map.json
	rm -f /esg/config/nm.properties
	
fi

