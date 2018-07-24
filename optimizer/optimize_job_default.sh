#!/bin/bash

if [ "$1" = "" ]; then
        echo "usage: sh getLog.sh TYPE CASE DEADLINE MAX_NODES"
        exit 0;
fi

TYPE=$1
CASE=$2
DEADLINE=$3
SMALL_NODE_MIN=$4
SMALL_NODE_MAX=$5
MEDIUM_NODE_MIN=$6
MEDIUM_NODE_MAX=$7
LARGE_NODE_MIN=$8
LARGE_NODE_MAX=$9

#declare -a TYPES=("wordcount"
#                  "terasort"
#                  "pagerank_stage1"
#                  "pagerank_stage2"
#                  "kmeans_iterator"
#                  "kmeans_classification"
#                  "trianglecount_triads"
#                  "trianglecount_triangles")

declare -a TYPES=("wordcount"
                  "terasort"
                  "pagerank_1"
                  "pagerank_2"
                  "kmeans_1"
                  "kmeans_2"
                  "trianglecount_1"
                  "trianglecount_2")

declare -a INPUTS=("wordcount"
                  "terasort"
                  "pagerank"
                  "pagerank"
                  "kmeans"
                  "kmeans"
                  "bfs"
                  "bfs")

job_type=${TYPES[$TYPE]}
job_input=${INPUTS[$TYPE]}

function optimize_main()
{
	TYPE=$1
	MIN_NODE=$2
	MAX_NODE=$3

	if [ "$MAX_NODE" != "0" ]
 	then

		random=$(od -vAn -N4 -tu4  /dev/urandom)
		RAND_CNT=$(echo "$random%$MAX_NODE+1" | bc)

		#sed -i "3c VMcount,$RAND_CNT,$NODE,1,int" optimizer/bound.csv
		#sed -i "4c VMtype,$TYPE,$TYPE,1,int" optimizer/bound.csv

		CONSTRAINT_FILE=constraint_default.csv

		#out=$(python optimizer/main.py --m optimizer/result/${job_type} --i optimizer/optimize_case/${job_input}_input_${CASE}.csv --d ${DEADLINE} 2> /dev/null)
		#out=$(python optimizer/client.py --m optimizer/result/${job_type} --i optimizer/optimize_case/${job_input}_input_${CASE}.csv --c optimizer/$CONSTRAINT_FILE 2> /dev/null)
		out=$(curl -X GET "http://0.0.0.0:9000" -d "${job_type},optimize_case/${job_input}_input_${CASE}.csv,${CONSTRAINT_FILE},${DEADLINE}" 2> /dev/null)
		tuned_time=$(echo "$out" | grep "Tuned time:" | cut -d':' -f2 | sed 's/ //g')
		tuned_node=$(echo "$out" | grep "Number of node:" | cut -d':' -f2 | sed 's/ //g')
		cpuhr=$((tuned_node*tuned_time))
		echo $tuned_node,$tuned_time,$cpuhr
	fi
}

best_output=""
best_cpuhr=100000000

small_str="0,"$(optimize_main 1 $SMALL_NODE_MIN $SMALL_NODE_MAX)
cpuhr=$(echo $small_str | cut -d, -f4)
if [ "$cpuhr" != "" ] && [ "$cpuhr" -lt "$best_cpuhr" ]
then
	best_cpuhr=$cpuhr
	best_output=$(echo $small_str | cut -d, -f1,2,3)
fi

medium_str="1,"$(optimize_main 3 $MEDIUM_NODE_MIN $MEDIUM_NODE_MAX)
cpuhr=$(echo $medium_str | cut -d, -f4)
if [ "$cpuhr" != "" ] && [ "$cpuhr" -lt "$best_cpuhr" ]
then
	best_cpuhr=$cpuhr
	best_output=$(echo $medium_str | cut -d, -f1,2,3)
fi

large_str="2,"$(optimize_main 6 $LARGE_NODE_MIN $LARGE_NODE_MAX)
cpuhr=$(echo $large_str | cut -d, -f4)
if [ "$cpuhr" != "" ] && [ "$cpuhr" -lt "$best_cpuhr" ]
then
	best_cpuhr=$cpuhr
	best_output=$(echo $large_str | cut -d, -f1,2,3)
fi

#echo $small_str
#echo $medium_str
#echo $large_str
echo $best_output
