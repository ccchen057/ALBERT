#!/bin/bash

if [ "$3" = "" ]; then
        echo "usage: sh genPredictionTrainingData.sh IN_FILE APP OUT_FILE"
        exit 0;
fi

rm $3

#data_size_list=$(cat $1 | jq .)

while IFS='' read -r line || [[ -n "$line" ]]; do

	job_state=$(echo $line | jq .job_state | tr -d '\"')
	#if [ "$job_state" = "SUCCEEDED" ]; then
		bash jsonFilter.sh \""$line"\" >> $3
		bash mergeInput.sh \""$line"\" $2 >> $3
		#bash mergeInput_tc1.sh \""$line"\" $2 >> $3
		#bash mergeInput_tc2.sh \""$line"\" $2 >> $3
		#bash mergeInput_pr1.sh \""$line"\" $2 >> $3
		#bash mergeInput_pr2.sh \""$line"\" $2 >> $3
		#APP=$(echo $3 | cut -d'.' -f2)
		#data=$(cat ../classification_training/log.${APP}.json | shuf | head -n1)
		#bash calMetric.sh \""$data"\" >> $3
		echo >> $3
	#fi

done < "$1"

bash first_label.sh $3
