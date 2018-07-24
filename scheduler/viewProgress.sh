#!/bin/bash

files=$(ls log.p_*)

for i in $files; do

	completed_job=$completed_job$(cat $i | grep "Packed" | cut -d' ' -f3,5,6 | tr '.,()=' ' ' | cut -d' ' -f1,7,8,16,17 | tr ' ' ','  | tail -n1 | cut -d',' -f1)"\n"

done

completed_job=$(echo -e "$completed_job" | sort -n -r)

echo "$completed_job"

for progress in $completed_job; do
	echo -n "["	
	for ((i=0; i<100; i++)); do

		if [ $((i*2)) -lt $progress ]; then
			echo -n "="
		else
			echo -n "."
		fi

	done
	echo -n "]"	

	echo -n " $progress/200"

	echo
done
