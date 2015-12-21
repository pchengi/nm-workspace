#!/bin/bash
source nm-helper.sh
esg_dist_url_root='http://esg-dn2.nsc.liu.se/esgf/dist'
hostname=`hostname -f`;

if env|grep NO_ESGF >/dev/null; then
	if [ $NO_ESGF -eq 1 ]; then 
		echo "Explicitly set to NO ESGF";
		setup_ca
		setup_apache_frontend
		rm -rf apache_frontend
	fi

else
	echo "There IS ESGF. Tread with care.";
fi
bash nm-prereqsetup.sh
setup_nm_conf
