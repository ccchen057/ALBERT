#!/bin/bash

if [ "$1" = "" ]; then
    echo "usage: bash exe.sh FILE NUM_BIG_JOB RAND_RANGE"
    exit 0;
fi
FILE=$1
L_CNT=$2
range=$3

cnt=0

while IFS='' read -r line || [[ -n "$line" ]]; do
	
	if [[ $cnt -lt $L_CNT ]]; then
		random=$(od -vAn -N4 -tu4  /dev/urandom)
		MIN_NODE=$(echo "$random%$range+1" | bc)
	else
		MIN_NODE=1
	fi

	echo "$line $MIN_NODE"
	cnt=$((cnt+1))

done < "${FILE}"
