#!/bin/bash
source nm-helper.sh
esg_dist_url='http://esg-dn2.nsc.liu.se/esgf/dist'
hostname=`hostname -f`;
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
	quotedsubststr=`echo $subststr|sed 's/[./*?|# ]/\\\\&/g'`;
	replstr2='"-days 30";\t# 30 days'
	subststr2='"-days 365";\t# 365 days'
	quotedreplstr2=`echo $replstr2|sed 's/[./*?|#\t]/\\\\&/g'`;
	quotedsubststr2=`echo $subststr2|sed 's/[./*?|# ]/\\\\&/g'`;
	sed -i "s/$quotedreplstr/$quotedsubststr/g" openssl.cnf
	sed -i "s/$quotedreplstr2/$quotedsubststr2/g" CA.pl
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

if env|grep HAS_ESGF >/dev/null; then
	if [ $HAS_ESGF -eq 0 ]; then 
		echo "Explicitly set to NO ESGF";
		setup_ca
	fi

else
	echo "There IS ESGF. Tread with care.";
fi
