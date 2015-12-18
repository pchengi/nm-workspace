#!/bin/bash


git pull
source ./setlocalpaths

bash nm-prereqsetup.sh
mkdir -p /esg/config /esg/tasks /esg/log
if [ ! -e /esg/config/esgf.properties ]; then
	echo "does not exist.  Will use defaults";
	cp esgf.properties /esg/config/
	hst=`hostname -f|tr '[a-z]' '[A-Z]'`;
	quotedhst=`echo $hst|sed 's/[./*?|]/\\\\&/g'`
	sed -i s/'pcmdi11\.llnl\.gov'/`hostname`/g /esg/config/esgf.properties
	sed -i s/'PCMDI11\.LLNL\.GOV'/$quotedhst/g /esg/config/esgf.properties
	echo 0 >/esg/config/config_type
fi
cp esgf_nodemgr_map.json /esg/config/
pushd  /root/esgf-nodemgr-doc/code
git pull
#bash run_server.sh
service nm-httpd start
/usr/local/bin/esgf-nm-ctl start
popd

