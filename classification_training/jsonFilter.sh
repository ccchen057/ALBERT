#!/bin/bash

if [ "$1" = "" ]; then
        echo "usage: sh jsonFilter.sh JSON"
        exit 0;
fi

data=${1:1:-1}

function jsonFilter() {

        for i in $@ ; do
		cmd=$cmd".\"$i\","
	done
        jq -r "[${cmd:0:-1}] | @csv"
}

info="
job_state
"

counters="
HDFS_WRITE_OPS.total
HDFS_WRITE_OPS.reduce
HDFS_WRITE_OPS.map
HDFS_LARGE_READ_OPS.total
HDFS_LARGE_READ_OPS.reduce
HDFS_LARGE_READ_OPS.map
HDFS_READ_OPS.total
HDFS_READ_OPS.reduce
HDFS_READ_OPS.map
HDFS_BYTES_WRITTEN.total
HDFS_BYTES_WRITTEN.reduce
HDFS_BYTES_WRITTEN.map
HDFS_BYTES_READ.total
HDFS_BYTES_READ.reduce
FILE_READ_OPS.reduce
FILE_READ_OPS.map
FILE_BYTES_WRITTEN.total
FILE_BYTES_WRITTEN.reduce
FILE_BYTES_WRITTEN.map
FILE_BYTES_READ.map
VCORES_MILLIS_MAPS.map
VCORES_MILLIS_MAPS.reduce
SHUFFLED_MAPS.total
FAILED_SHUFFLE.map
REDUCE_OUTPUT_RECORDS.reduce
REDUCE_OUTPUT_RECORDS.map
REDUCE_INPUT_RECORDS.total
REDUCE_INPUT_RECORDS.reduce
REDUCE_INPUT_RECORDS.map
REDUCE_SHUFFLE_BYTES.total
REDUCE_SHUFFLE_BYTES.reduce
REDUCE_SHUFFLE_BYTES.map
MILLIS_REDUCES.total
MILLIS_REDUCES.reduce
MILLIS_REDUCES.map
MILLIS_MAPS.total
MILLIS_MAPS.reduce
MILLIS_MAPS.map
SLOTS_MILLIS_REDUCES.total
SLOTS_MILLIS_REDUCES.reduce
SLOTS_MILLIS_REDUCES.map
SLOTS_MILLIS_MAPS.total
SLOTS_MILLIS_MAPS.reduce
SLOTS_MILLIS_MAPS.map
RACK_LOCAL_MAPS.total
RACK_LOCAL_MAPS.reduce
RACK_LOCAL_MAPS.map
TOTAL_LAUNCHED_REDUCES.total
TOTAL_LAUNCHED_REDUCES.reduce
TOTAL_LAUNCHED_REDUCES.map
TOTAL_LAUNCHED_MAPS.total
TOTAL_LAUNCHED_MAPS.reduce
TOTAL_LAUNCHED_MAPS.map
NUM_KILLED_MAPS.total
MAP_INPUT_RECORDS.total
MAP_OUTPUT_RECORDS.map
MAP_OUTPUT_RECORDS.reduce
MAP_OUTPUT_RECORDS.total
MAP_OUTPUT_BYTES.map
MAP_OUTPUT_BYTES.reduce
MAP_OUTPUT_BYTES.total
MAP_OUTPUT_MATERIALIZED_BYTES.map
COMBINE_INPUT_RECORDS.total
COMBINE_INPUT_RECORDS.reduce
COMBINE_INPUT_RECORDS.map
SPLIT_RAW_BYTES.total
SPLIT_RAW_BYTES.reduce
SPLIT_RAW_BYTES.map
MAP_OUTPUT_MATERIALIZED_BYTES.total
MAP_OUTPUT_MATERIALIZED_BYTES.reduce
MAP_INPUT_RECORDS.reduce
MAP_INPUT_RECORDS.map
MB_MILLIS_REDUCES.total
MB_MILLIS_REDUCES.reduce
NUM_KILLED_MAPS.reduce
NUM_KILLED_MAPS.map
BAD_ID.map
BAD_ID.reduce
PHYSICAL_MEMORY_BYTES.total
PHYSICAL_MEMORY_BYTES.reduce
PHYSICAL_MEMORY_BYTES.map
CPU_MILLISECONDS.total
CPU_MILLISECONDS.reduce
CPU_MILLISECONDS.map
GC_TIME_MILLIS.total
GC_TIME_MILLIS.reduce
SHUFFLED_MAPS.reduce
SHUFFLED_MAPS.map
SPILLED_RECORDS.total
SPILLED_RECORDS.reduce
SPILLED_RECORDS.map
REDUCE_OUTPUT_RECORDS.total
REDUCE_INPUT_GROUPS.total
REDUCE_INPUT_GROUPS.reduce
REDUCE_INPUT_GROUPS.map
COMBINE_OUTPUT_RECORDS.total
COMBINE_OUTPUT_RECORDS.reduce
COMBINE_OUTPUT_RECORDS.map
BYTES_WRITTEN.reduce
BYTES_WRITTEN.total
WRONG_REDUCE.map
WRONG_MAP.total
WRONG_MAP.reduce
WRONG_MAP.map
WRONG_LENGTH.total
WRONG_LENGTH.reduce
WRONG_LENGTH.map
IO_ERROR.total
COMMITTED_HEAP_BYTES.total
COMMITTED_HEAP_BYTES.reduce
COMMITTED_HEAP_BYTES.map
VIRTUAL_MEMORY_BYTES.total
VIRTUAL_MEMORY_BYTES.reduce
VIRTUAL_MEMORY_BYTES.map
GC_TIME_MILLIS.map
MERGED_MAP_OUTPUTS.total
MERGED_MAP_OUTPUTS.reduce
MERGED_MAP_OUTPUTS.map
FAILED_SHUFFLE.total
FAILED_SHUFFLE.reduce
FILE_BYTES_READ.reduce
FILE_BYTES_READ.total
FILE_READ_OPS.total
FILE_LARGE_READ_OPS.map
FILE_LARGE_READ_OPS.reduce
FILE_LARGE_READ_OPS.total
FILE_WRITE_OPS.map
FILE_WRITE_OPS.reduce
FILE_WRITE_OPS.total
HDFS_BYTES_READ.map
BYTES_WRITTEN.map
BYTES_READ.total
BYTES_READ.reduce
BYTES_READ.map
WRONG_REDUCE.total
WRONG_REDUCE.reduce
IO_ERROR.reduce
IO_ERROR.map
CONNECTION.total
CONNECTION.reduce
CONNECTION.map
BAD_ID.total
MB_MILLIS_REDUCES.map
MB_MILLIS_MAPS.total
MB_MILLIS_MAPS.reduce
MB_MILLIS_MAPS.map
VCORES_MILLIS_REDUCES.total
VCORES_MILLIS_REDUCES.reduce
VCORES_MILLIS_REDUCES.map
VCORES_MILLIS_MAPS.total
CONVERGE_CHECK.reduce
CONVERGE_CHECK.total
CONVERGE_CHECK.map
"

job="
startTime
finishTime
"
output=""
job_name=$(echo $data | jq '.job_name' | tr -d '\"')
if [[ "${job_name:0:22}" == "Cluster Classification" ]]; then
	output=$output$(echo -n "Cluster Classification")","
elif [[ "${job_name:0:16}" == "Cluster Iterator" ]]; then
	output=$output$(echo -n "Cluster Iterator")","
else
	output=$output$(echo -n "$job_name")","
fi
	
#output=$output$(echo $data | jsonFilter $info)","
#output=$output$(echo $data | jq .counters | jsonFilter $counters | tr -d '\"')","

#echo ${output:0:-1}
echo -n ${output}
