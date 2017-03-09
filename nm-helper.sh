#!/bin/bash
write_ca_ans_templ(){
cat <<EOF



placeholder.fqdn-CA



EOF
}
write_reqhost.ans_templ(){
cat <<EOF


placeholder.fqdn


EOF
}
print_templ() {
cat <<EOF
# ca-signing-policy.conf, see ca-signing-policy.doc for more information
#
# This is the configuration file describing the policy for what CAs are
# allowed to sign whoses certificates.
#
# This file is parsed from start to finish with a given CA and subject
# name.
# subject names may include the following wildcard characters:
#    *    Matches any number of characters.
#    ?    Matches any single character.
#
# CA names must be specified (no wildcards). Names containing whitespaces
# must be included in single quotes, e.g. 'Certification Authority'.
# Names must not contain new line symbols.
# The value of condition attribute is represented as a set of regular
# expressions. Each regular expression must be included in double quotes.
#
# This policy file dictates the following policy:
#   -The Globus CA can sign Globus certificates
#
# Format:
#------------------------------------------------------------------------
#  token type  | def.authority |                value
#--------------|---------------|-----------------------------------------
# EACL entry #1|

 access_id_CA      X509         '/O=ESGF/OU=ESGF.ORG/CN=placeholder'

 pos_rights        globus        CA:sign

 cond_subjects     globus       '"/O=ESGF/OU=ESGF.ORG/*"'

# end of EACL
EOF
}

setup_ca(){
	mkdir -p /etc/tempcerts;
	pushd /etc/tempcerts && rm -rf CA; rm -f *.pem; rm -f *.gz; rm -f *.ans; rm -f *.tmpl
	mkdir CA
	write_ca_ans_templ >setupca.ans.tmpl
	write_reqhost.ans_templ >reqhost.ans.tmpl
	echo -e "y\ny" >setuphost.ans
	cat setupca.ans.tmpl|sed  "s/placeholder.fqdn/$hostname/" >setupca.ans
	cat reqhost.ans.tmpl|sed  "s/placeholder.fqdn/$hostname/" >reqhost.ans
	curl -s -L --insecure ${esg_dist_url_root}/esgf-installer/CA.pl >CA.pl
	curl -s -L --insecure ${esg_dist_url_root}/esgf-installer/openssl.cnf >openssl.cnf
	replstr='default_days\t= 30\t\t\t# how long to certify for'
	subststr='default_days\t= 365\t\t\t# how long to certify for'
	quotedreplstr=`echo $replstr|sed 's/[./*?|#\t]/\\\\&/g'`;
	quotedsubststr=`echo $subststr|sed 's/[./*?|#\t]/\\\\&/g'`;
	repl2str='"-days 30";\t# 30 days'
	subst2str='"-days 365";\t# 365 days'
	quoted2replstr=`echo $repl2str|sed 's/[./*?|#\t"]/\\\\&/g'`;
	quoted2subststr=`echo $subst2str|sed 's/[./*?|#\t"]/\\\\&/g'`;
	sed -i "s/$quotedreplstr/$quotedsubststr/g" openssl.cnf
	sed -i "s/$quoted2replstr/$quoted2subststr/g" CA.pl
	perl CA.pl -newca <setupca.ans
	openssl rsa -in CA/private/cakey.pem -out clearkey.pem -passin pass:placeholderpass && mv clearkey.pem CA/private/cakey.pem
	perl CA.pl -newreq-nodes <reqhost.ans
	perl CA.pl -sign <setuphost.ans
	openssl x509 -in CA/cacert.pem -inform pem -outform pem >cacert.pem
	cp CA/private/cakey.pem cakey.pem
	openssl x509 -in newcert.pem -inform pem -outform pem >hostcert.pem
	mv newkey.pem hostkey.pem
	chmod 400 cakey.pem
	chmod 400 hostkey.pem
	rm -f new*.pem
	ESGF_OPENSSL=/usr/bin/openssl
	cert=cacert.pem
	tmpsubj='/O=ESGF/OU=ESGF.ORG/CN=placeholder'
	quotedtmpsubj=`echo "$tmpsubj" | sed 's/[./*?|]/\\\\&/g'`;
	certsubj=`openssl x509 -in $cert -noout -subject|cut -d ' ' -f2-`;
	quotedcertsubj=`echo "$certsubj" | sed 's/[./*?|]/\\\\&/g'`;
	echo "quotedcertsubj=~$quotedcertsubj~";
	localhash=`$ESGF_OPENSSL x509 -in $cert -noout -hash`;
	tgtdir="globus_simple_ca_${localhash}_setup-0";
	mkdir $tgtdir;
	cp $cert $tgtdir/${localhash}.0;
	print_templ >signing_policy_template;
	sed "s/\(.*\)$quotedtmpsubj\(.*\)/\1$quotedcertsubj\2/" signing_policy_template >$tgtdir/${localhash}.signing_policy;
	cp $tgtdir/${localhash}.signing_policy signing-policy
	tar -cvzf globus_simple_ca_${localhash}_setup-0.tar.gz $tgtdir;
	rm -rf $tgtdir;
	rm -f signing_policy_template;
	mkdir -p /etc/certs
	cp openssl.cnf /etc/certs/
	cp host*.pem /etc/certs/
	cp cacert.pem /etc/certs/cachain.pem
	popd
}
setup_apache_frontend(){
	mkdir /root/apache_frontend;
	pushd /root/apache_frontend
	git clone https://github.com/ESGF/apache-frontend.git;
	pushd apache-frontend
	git checkout nm_sec


	bash setup_python.sh "na" "na"
	mkdir -p /opt/esgf/flaskdemo/demo
	cp wsgi/demo/* /opt/esgf/flaskdemo/demo
	chown -R apache:apache /opt/esgf/flaskdemo/demo
	chkconfig --levels 345 httpd off
	popd; popd;
}
setup_nm_conf(){

	servername=`hostname -f`;

	if env|grep HAS_ESGF >/dev/null; then
		if [ $HAS_ESGF -eq 1 ]; then

			popd; popd

			mystr=''; while read ln; do mystr=${mystr}\\n\\t"$ln"; done <nm-httpconf-lines
			quotedmystr=`echo $mystr|sed 's/[./*?|#%!^]/\\\\&/g'`

			sed -i "s/WSGIDaemonProcess\ cog\-site/$quotedmystr/" /etc/httpd/conf/esgf-httpd.conf

			peergroup=`grep node.peer.group /esg/config/esgf.properties | cut -d'=' -f 2`
			if [ $peergroup == "esgf-demo" ] ; then
			    FED_NAME="demonet"
			    else
			    FED_NAME=$peergroup
			fi


		fi
	else

		if [ ! -d /root/apache_frontend/apache-frontend ]; then
			mkdir /root/apache_frontend;
			pushd /root/apache_frontend
			git clone https://github.com/ESGF/apache-frontend.git;
			pushd apache-frontend
			git checkout nm_sec;
		else
			pushd /root/apache_frontend
			pushd apache-frontend;
			git checkout nm_sec;
			git pull;
		fi		


	    if [ -z $FED_NAME ] ; then

		   FED_NAME=demonet
	    fi
		tmpservername='placeholder.fqdn'

		quotedtmpservername=`echo "$tmpservername" | sed 's/[./*?|]/\\\\&/g'`;
		quotedservername=`echo "$servername" | sed 's/[./*?|]/\\\\&/g'`;
		cp etc/init.d/nm-httpd.tmpl etc/init.d/nm-httpd;
		cp etc/certs/esgf-ca-bundle.crt /etc/certs/
	
		sed "s/\(.*\)$quotedtmpservername\(.*\)/\1$quotedservername\2/" etc/httpd/conf/nm-httpd.conf.tmpl >etc/httpd/conf/nm-httpd.conf;

		LD_LIBRARY_PATH=/opt/esgf/python/lib:/opt/esgf/python/lib/python2.7:/opt/esgf/python/lib/python2.7/site-packages/mod_wsgi/server
		quotedldpath=`echo "$LD_LIBRARY_PATH"|sed 's/[./*?|"]/\\\\&/g'`
		quotedwsgipath=`echo "/opt/esgf/python/lib/python2.7/site-packages/mod_wsgi/server/mod_wsgi-py27.so"|sed 's/[./*?|"]/\\\\&/g'`
		sed -i "s/\(.*\)LD_LIBRARY_PATH=placeholderldval\(.*\)/\1LD_LIBRARY_PATH=$quotedldpath\2/" etc/init.d/nm-httpd;
		sed -i "s/\(.*\)LoadModule wsgi_module placeholder_so\(.*\)/\1LoadModule wsgi_module $quotedwsgipath\2/" etc/httpd/conf/nm-httpd.conf;
		cp etc/httpd/conf/nm-httpd.conf /etc/httpd/conf/
		cp etc/init.d/nm-httpd /etc/init.d/
		popd; popd;
 
	fi
	# this can be integrated into the installer
	INST_DIR=/usr/local
	quotedinstdir=`echo $INST_DIR|sed 's/[./*?|#\t]/\\\\&/g'`
	NM_DIR=$INST_DIR/esgf-node-manager/src
	PREFIX=__prefix__
	pushd $INST_DIR
	if [ ! -d esgf-node-manager ]; then
		git clone https://github.com/ESGF/esgf-node-manager.git
	else
	    export GIT_SSL_NO_VERIFY=true
	    pushd esgf-node-manager && git pull;
	    popd
	fi
	popd

	pushd $NM_DIR	
	git checkout devel

	#generate a secret key and apply to the settings
	d=`date`
	sk=`echo $d $servername | sha256sum | awk '{print $1}'`

	sed -i s/changeme1/$sk python/server/nodemgr/nodemgr/settings.py
	sed -i s/changeme2/$servername python/server/nodemgr/nodemgr/settings.py
	popd


	cp $NM_DIR/scripts/esgf-nm-ctl $INST_DIR/bin/esgf-nm-ctl


	chmod u+x $INST_DIR/bin/esgf-nm-ctl  $NM_DIR/scripts/esgfnmd
	adduser nodemgr
	usermod -a -G tomcat nodemgr

	usermod -a -G apache nodemgr

	mkdir -p /esg/log /esg/tasks /esg/config

	touch /esg/log/django.log
	touch /esg/log/esgf_nm.log
	touch /esg/log/esgf_nm_dj.log
	touch /esg/log/esgfnmd.out.log
	touch /esg/log/esgfnmd.err.log
	touch /esg/config/nm.properties
	touch /esg/config/registration.xml

	wget -O /esg/config/timestamp http://aims1.llnl.gov/nm-cfg/timestamp
	wget -O /esg/config/esgf_supernodes_list.json http://aims1.llnl.gov/nm-cfg/$FED_NAME/esgf_supernodes_list.json

	chown nodemgr:nodemgr /esg/log/esgf_nm.log
	chown nodemgr:nodemgr /esg/log/esgfnmd.out.log
	chown nodemgr:nodemgr /esg/log/esgfnmd.err.log
	chown nodemgr:apache /esg/config/nm.properties
	chown nodemgr:apache /esg/config/registration.xml
	chown nodemgr:nodemgr /esg/config/timestamp
	chown nodemgr:nodemgr /esg/config/esgf_supernodes_list.json
	chmod 777 /esg/tasks
	chown nodemgr:nodemgr $NM_DIR/scripts/esgfnmd
	chown apache:apache /esg/log/esgf_nm_dj.log
	chown apache:apache /esg/log/django.log
	
	
	if [ ! -z $HAS_ESGF ] ; then
		if [ $HAS_ESGF == 1] ; then
			chmod g+r /esg/config/.esg_pg_pass
		fi
	fi
	#rm -rf /root/apache_frontend
	pushd $NM_DIR/python/server

	fqdn=`grep esgf.host= /esg/config/esgf.properties | cut -d'=' -f 2`
	cmd="python gen_nodemap.py $NM_INIT $fqdn"
	echo $cmd
	$cmd
	chmod 755 /esg/config/esgf_nodemgr_map.json
	chown nodemgr:apache /esg/config/esgf_nodemgr_map.json

	popd

}
