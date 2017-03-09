# nm-workspace

How to install the node manager (unitl we integrate it into the installer)

Standalone, eg. for a Docker container:

  1) bash nm-installer.sh

  2) service nm-httpd start

  3) curl --insecure http://<FQDN>/esgf-nm  - should return a default response

  4) esgf-nm-ctl start

  5) esgf-nm-ctl status – should keep running

  6) If any problems check logs either in /esg/logs or /var/log/httpd/error_log 



With ESGF:

  1) Install ESGF – the choice of peer group is now crucial

    A)  If in a private vm environment using the demonet named instances, use esgf-demo as your peer group

    B)  If on an open node out on internet to participate in the test federation, use esgf-test as your peer group (confirm its set in esgf.properties)


          i) When you’re ready to run a test node as a supernode, I’ll need to update the supernode list on aims1 with the fqdn - contact Sasha (ames4@llnl.gov).

    C)  A transistion to esgf-prod is TBD

  2) git clone the nm-workspace repo

  3) Strongly recommended to back up your current esgf installation in case anything goes wrong.   The most crucial file to back up is /etc/httpd/conf/esgf-httpd.conf as the nm-installer does change this

  4) export HAS_ESGF=1

  5) bash nm-installer.sh

The control files referenced in steps 5, 7, 8 are put into /usr/local/bin (path assumed)

  6) esg-node restart

  7) curl http://localhost/esgf-nm  - should work  (if doesn't there's a manual setup)

  8) esgf-nm-ctl start

  9) esgf-nm-ctl status – should keep running

  10) If any problems check logs either in /esg/logs or /var/log/httpd/error_log

  11)  If you are running a membernode:
       python /usr/local/esgf-nodemgr-doc/code/server/member_node_cmd.py add \<project\> 0

      For now the name of the project isn't relevant, but might be in the future when the node manager manages configurations for "virtual organizations"

      
Troubleshooting:
 - previous versions of  esg-node automatically call "update_apache_conf".  If step (6) above does not work, comment line 5223 (or check first) of esg-node to disable the update. 

