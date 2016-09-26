v=1

lst_cmd="python json2lst.py /opt/nm/esgf-test/esgf_supernodes_list.json"

d=0


for line in `$lst_cmd` ; do
    
    mkdir -p $DATA_DIR/$line
    mkdir -p $DATA_DIR/$line/$d   

done 

t=0



while [ $v == $v  ]  ; do

    for sn in `$lst_cmd` ; do

	
	curl http://$sn/esgf-nm/api?action=sync_node_map_file > $DATA_DIR/$sn/$d/$d.$t.json   


    done  

    sleep 5


    t=$(( $t + 1 ))

    if [ $t == 1000 ] ; then

	d=$(( $d + 1 ))
	t=0

	for line in `$lst_cmd` ; do
    

	    mkdir -p $DATA_DIR/$line/$d   

	done 
	
	
    fi
    
done