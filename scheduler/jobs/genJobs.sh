#!/bin/bash

if [ "$3" = "" ]; then
    echo "usage: bash genJobs.sh NUM_JOBS RATIO OUT_FILE"
    exit 0;
fi

JOB_NUM=$1
RATIO=$2
outfile=$3

rm tmp.job.txt
declare -a SIZES=("1" "2" "3" "4")

for (( j=1; j<=$JOB_NUM; j++ )) do
	index=$(bash genRandom.sh 0 7)
	#index=2
	case=$(python ZipfGenerator.py --a ${RATIO})
	#echo $case
	size=${SIZES[$case]}	
	#echo $size
	default_time=$(bash ../../optimizer/optimize_job_default.sh $index $size 10000000000 0 0 0 0 1 1 | cut -d, -f3)
	echo $index" "$size" "$default_time >> tmp.job.txt
done

cat tmp.job.txt | sort -n -k 3 -r > $outfile
rm tmp.job.txt
