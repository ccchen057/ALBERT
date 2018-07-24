#!/bin/bash

if [ "$1" = "" ]; then
        echo "usage: sh first_label.sh IN_FILE"
        exit 0;
fi

label="0,1,1"
num_feature=$(head -n 1 $1 | grep -o , | wc -l)
#echo $num_feature
for ((i=0;i<$((num_feature-2));i++)); do
        label=$label$(echo -n ",0")
done

sed -i 1"i\\$label" $1

#echo $label
#num_feature=$(echo $label | grep -o , | wc -l)
#echo $num_feature

#exit 0

sed -i "s/"m1.small"/1/g" $1
sed -i "s/"m1.medium"/3/g" $1
sed -i "s/"m1.large"/6/g" $1
sed -i "s/"m1.xlarge"/12/g" $1

sed -i "s/-Xmx//g" $1
sed -i "s/m//g" $1

