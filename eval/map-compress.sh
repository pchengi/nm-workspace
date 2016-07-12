

for node in `ls` ; do

    complete="0"


    for i in `ls $node | sort -n` ; do


	for j in `seq 0 998` ; do
	    nextj=$(( $j + 1 ))
	    
	    nextfn="$node/$i/$i.${nextj}.json"
	    if [ -f $nextfn ] ; then

		thisfn="$node/$i/$i.${j}.json"
		ts=`stat -c"%Z" $nextfn`
		dc=`diff $thisfn $nextfn | wc -l`
		if [ $dc -gt 0 ] ; then
		    cp $nextfn ../comp-data/$node.$ts.json
		fi
		
	    else
		complete="1"
	    fi
	
	done
	    if [ $complete == "0" ] ; then
		nexti=$(( $i + 1 ))
		thisfn="$node/$i/$i.999.json"
		nextfn="$node/${nexti}/${nexti}.0.json"
		dc=`diff $thisfn $nextfn | wc -l`
		if [ $dc -gt 0 ] ; then
		    cp $nextfn ../comp-data/$node.$ts.json
		fi
	    fi
    done


done