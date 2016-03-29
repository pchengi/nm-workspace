# nm-workspace

How to install the node manager (unitl we integrate it into the installer)

1) Install ESGF – the choice of peer group is now crucial

    A)  If in a private vm environment using the demonet named instances, use esgf-demo as your peer group

    B)  If on an open node out on internet to participate in the test federation, use esgf-test 

          i) When you’re ready to run a test node as a supernode, I’ll need to update the supernode list on aims1 with the fqdn

2) git clone the nm-workspace repo

3) bash nm-installer.sh

4) esg-node restart

5)  curl http://localhost/esgf-nm  - should work

6) esgf-nm-ctl start

7) esgf-nm-ctl status – should keep running

8) If any problems check logs either in /esg/logs or /var/log/httpd/error_log

9) If you are running a membernode, python /usr/local/esgf-nodemgr-doc/code/server/member_node_cmd.py add <project> 0

     For now the name of the project isn't relevant, but might be in the future when the node manager manages configurations for "virtual organization

4, 6, 7 are put into /usr/local/bin
