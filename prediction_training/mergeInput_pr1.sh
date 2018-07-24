#!/bin/bash

if [ "$2" = "" ]; then
        echo "usage: sh mergeInput.sh JSON APP"
        exit 0;
fi

data=${1:1:-1}
app=$2
input_size=$(echo $data | jq .counters | jq '."BYTES_READ.total"')
if [[ "$input_size" -lt 200703330 ]]; then
	input_size=1811191
elif [[ "$input_size" -lt 459158993 ]]; then
	input_size=259947887
elif [[ "$input_size" -lt 701003260 ]]; then
	input_size=531470496
else
	input_size=2993448066
fi
	

#echo $input_size

for i in {1..4}; do
	input_size_file=$(cat ../profiler/predict_case/${2}_input_${i}.csv | cut -d',' -f1)
	error=$((input_size_file-input_size))
	if [[ $error -lt 0 ]]; then
        	error=$((error*-1))
	fi
	list=${list}${error}","${i}"\n"
done

index=$(echo -e "$list" | sort -k1 -n | grep -v "^$" | head -1 | cut -d',' -f2)
#echo $index
echo -n $(cat ../profiler/predict_case/${2}_input_${index}.csv)
