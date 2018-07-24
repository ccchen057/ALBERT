#!/bin/bash

if [ "$2" = "" ]; then
        echo "usage: sh mergeInput.sh JSON APP"
        exit 0;
fi

data=${1:1:-1}
app=$2
input_size=$(echo $data | jq .counters | jq '."BYTES_READ.total"')
input_size=$(echo "$input_size * 0.006" | bc | cut -d'.' -f1)

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
