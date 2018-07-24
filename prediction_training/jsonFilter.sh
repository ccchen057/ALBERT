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
job_name
instance_count
instance_type
"

counters="
HDFS_BYTES_READ.map
"

job="
startTime
finishTime
"

conf="
mapreduce.job.reduces
mapreduce.tasktracker.map.tasks.maximum
mapreduce.tasktracker.reduce.tasks.maximum
mapreduce.task.io.sort.mb
mapreduce.task.io.sort.factor
mapreduce.reduce.shuffle.parallelcopies
mapreduce.reduce.shuffle.input.buffer.percent
mapreduce.reduce.shuffle.merge.percent
mapreduce.reduce.shuffle.memory.limit.percent
mapreduce.map.sort.spill.percent
mapreduce.reduce.input.buffer.percent
mapreduce.reduce.merge.inmem.threshold
mapreduce.job.reduce.slowstart.completedmaps
mapreduce.jobtracker.handler.count
mapreduce.tasktracker.http.threads
mapreduce.map.cpu.vcores
mapreduce.reduce.cpu.vcores
mapreduce.map.memory.mb
mapreduce.reduce.memory.mb
yarn.app.mapreduce.am.resource.mb
yarn.app.mapreduce.am.resource.cpu-vcores
mapreduce.input.fileinputformat.split.minsize
mapred.child.java.opts
"

output=""
output=$output$(echo $data | jq '.job.finishTime - .job.startTime')","
output=$output$(echo $data | jsonFilter $info)","
#output=$output$(echo $data | jq .counters | jsonFilter $counters | tr -d '\"')","
output=$output$(echo $data | jq .conf | jsonFilter $conf | tr -d '\"')","

#echo ${output:0:-1}
echo -n ${output}
