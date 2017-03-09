#!/bin/bash
source nm-helper.sh
esg_dist_url_root='http://esg-dn2.nsc.liu.se/esgf/dist'
hostname=`hostname -f`;


if [ -z $HAS_ESGF ]; then 
	echo "Explicitly set to NO ESGF";
	if [ ! -e /esg/config/esgf.properties ]; then
		echo "does not exist.  Will use defaults";
		mkdir -p /esg/config
		cp esgf.properties /esg/config/
		hst=`hostname -f|tr '[a-z]' '[A-Z]'`;
		quotedhst=`echo $hst|sed 's/[./*?|]/\\\\&/g'`
		sed -i s/'pcmdi11\.llnl\.gov'/`hostname`/g /esg/config/esgf.properties
		sed -i s/'PCMDI11\.LLNL\.GOV'/$quotedhst/g /esg/config/esgf.properties
		echo 0 >/esg/config/config_type
	fi
	setup_ca
	setup_apache_frontend
	rm -rf apache_frontend

else
	echo "There IS ESGF. Tread with care.";
fi
bash nm-prereqsetup.sh
setup_nm_conf

chown nodemgr:nodemgr /esg/config/esgf_nodemgr_map.json
chmod a+r /esg/config/esgf_nodemgr_map.json

