#!/bin/bash

if [ "$1" = "" ]; then
        echo "usage: sh jsonFilter.sh JSON"
        exit 0;
fi

data=${1:1:-1}

data=$(echo "$data" | jq ".metric[].aggregate" | jq -s '.')
NUM_METRIC=6
NUM_NODE=3
PERIOD=4

for ((i=0; i<$NUM_METRIC; i++)); do
	for ((j=0; j<$PERIOD; j++)); do
		
		declare -a array=(0 0 0 0 0)
		index=""
		for ((k=0; k<$NUM_NODE; k++)); do
			index=$index$((i*NUM_NODE*PERIOD + j + k*PERIOD))","
		done
		index=${index:0:-1}
		#echo $index
		#echo "$data" | jq ".[($index)]"
		reduce=$(echo "$data" | jq ".[($index)]" | jq -n 'reduce (inputs | to_entries[]) as $i ({}; .[$i.key] += ($i.value/'$NUM_NODE'))')
		#echo $reduce | jq .
		for m in {sum,avg,max,min,stddev}; do
			result=$(echo "$reduce" | jq .$m)
			if [ "$result" == "null" ]; then
				echo -n "0,"
			else
				echo -n "$result,"
			fi
		done
	done
done
