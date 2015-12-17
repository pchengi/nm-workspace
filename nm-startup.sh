#!/bin/bash

source ./setlocalpaths
mkdir -p /esg/config /esg/tasks /esg/log
if [ ! -e /esg/config/esgf.properties ]; then
	echo "does not exist.  Will use defaults";
	cp esgf.properties /esg/config/
	hst=`hostname -f|tr '[a-z]' '[A-Z]'`;
	quotedhst=`echo $hst|sed 's/[./*?|]/\\\\&/g'`
	sed -i s/'pcmdi11\.llnl\.gov'/`hostname`/g /esg/config/esgf.properties
	sed -i s/'PCMDI11\.LLNL\.GOV'/$quotedhst/g /esg/config/esgf.properties
	cp esgf_nodemgr_map.json /esg/config/
	echo 0 >/esg/config/config_type
fi
