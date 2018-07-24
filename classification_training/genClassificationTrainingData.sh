#!/bin/bash

if [ "$3" = "" ]; then
        echo "usage: sh genClassificationTrainingData.sh FILE APP OUT_FILE"
        exit 0;
fi

rm $3

counter=0
while IFS='' read -r line || [[ -n "$line" ]]; do
	counter=$((counter+1))
	#echo $counter >&2
	job_state=$(echo $line | jq .job_state | tr -d '\"')
	if [ "$job_state" = "SUCCEEDED" ]; then
		#echo counters >&2
		bash jsonFilter.sh \""$line"\" >> $3
		bash mergeInput.sh \""$line"\" $2 >> $3 
		bash calMetric.sh \""$line"\" >> $3
		echo >> $3
	fi

done < "$1"

exit 0
label="1"
num_feature=$(head -n 1 $3 | grep -o , | wc -l)
#echo $num_feature
for ((i=0;i<$((num_feature-0));i++)); do
        label=$label$(echo -n ",0")
done

sed -i 1"i\\$label" $3
