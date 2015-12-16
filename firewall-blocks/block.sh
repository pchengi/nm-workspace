#!/bin/bash

echo -n >iptables-blocks;
chmod 600 iptables-blocks;
run_firewall(){
	echo -n >iptables-active;
	chmod 600 iptables-active;
	cat iptables-boilerplate >>iptables-active
	cat iptables-blocks >>iptables-active
	cat iptables-rules >>iptables-active
	#echo "check iptables-active";
	bash iptables-active
	exit 0;
}
clear
while [ 1 ]; do
	cat <<EOF
Enter fqdn of node to block, or 
'all' to block all, or 
q to quit without blocking any node, or
s to save and quit with your choices.
EOF
	read -e inp;
	if [ "$inp" = 'q' -o "$inp" = "all" -o "$inp" = 's' ]; then
		break;
	fi
	if grep -w "$inp" allnodes >/dev/null; then
		if grep -w "$inp" iptables-blocks >/dev/null; then
			clear;
			continue;
		else
			if [ "$inp" = "$HOSTNAME" ]; then
				clear;
				continue;
			fi
			echo "iptables -A INPUT -s $inp -j DROP" >>iptables-blocks;
		fi
	else
		clear;
		continue;
	fi
	clear;
done
if [ "$inp" = 'q' ]; then
	echo -n >iptables-blocks;
	run_firewall
fi
if [ "$inp" = "all" ]; then
	echo -n >iptables-blocks;
	while read ln; do
		if [ "$ln" = "$HOSTNAME" ]; then
			continue;
		fi
		echo "iptables -A INPUT -s $ln -j DROP" >>iptables-blocks;
	done <allnodes
	run_firewall
fi
run_firewall

