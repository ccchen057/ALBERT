#!/bin/bash

if [ "$1" = "" ]; then
	echo "usage: sh addLabel.sh FILE"
	exit 0;
fi

FILE=$1

label="1"
num_feature=$(head -n 1 $FILE | grep -o , | wc -l)
#echo $num_feature
for ((i=0;i<$((num_feature-0));i++)); do
        label=$label$(echo -n ",0")
done

sed -i 1"i\\$label" $FILE
