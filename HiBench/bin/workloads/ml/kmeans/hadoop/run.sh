#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

current_dir=`dirname "$0"`
current_dir=`cd "$current_dir"; pwd`
root_dir=${current_dir}/../../../../../
workload_config=${root_dir}/conf/workloads/ml/kmeans.conf
. "${root_dir}/bin/functions/load-bench-config.sh"

enter_bench HadoopKmeans ${workload_config} ${current_dir}
show_bannar start

ensure-mahout-release

rmr-hdfs $OUTPUT_HDFS || true

INPUT_SAMPLE=${INPUT_HDFS}_4/samples
INPUT_CLUSTER=${INPUT_HDFS}_4/cluster

SIZE=`dir_size ${INPUT_HDFS}_4`
OPTION="-i ${INPUT_SAMPLE} \
	-c ${INPUT_CLUSTER} \
	-x ${MAX_ITERATION} \
	-ow \
	-cl \
	-cd 0.5 \
	-dm org.apache.mahout.common.distance.EuclideanDistanceMeasure \
	-xm mapreduce \
        -Dmapreduce.job.reduces=9 \
        -Dmapreduce.tasktracker.map.tasks.maximum=8 \
        -Dmapreduce.tasktracker.reduce.tasks.maximum=2 \
        -Dmapreduce.task.io.sort.mb=140 \
        -Dmapreduce.task.io.sort.factor=90 \
        -Dmapreduce.reduce.shuffle.parallelcopies=20 \
        -Dmapreduce.reduce.shuffle.input.buffer.percent=.7 \
        -Dmapreduce.reduce.shuffle.merge.percent=.75 \
        -Dmapreduce.reduce.shuffle.memory.limit.percent=.5 \
        -Dmapreduce.map.sort.spill.percent=.7 \
        -Dmapreduce.reduce.input.buffer.percent=.9 \
        -Dmapreduce.reduce.merge.inmem.threshold=500 \
        -Dmapreduce.job.reduce.slowstart.completedmaps=.40 \
        -Dmapreduce.jobtracker.handler.count=100 \
        -Dmapreduce.tasktracker.http.threads=60 \
        -Dmapreduce.map.cpu.vcores=4 \
        -Dmapreduce.reduce.cpu.vcores=2 \
        -Dmapreduce.map.memory.mb=1024 \
        -Dmapreduce.reduce.memory.mb=1408 \
        -Dyarn.app.mapreduce.am.resource.mb=1024 \
        -Dyarn.app.mapreduce.am.resource.cpu-vcores=2 \
        -Dmapred.child.java.opts=-Xmx815m \
	-o ${OUTPUT_HDFS} \
	"
CMD="${MAHOUT_HOME}/bin/mahout kmeans  ${OPTION}"
MONITOR_PID=`start-monitor`
START_TIME=`timestamp`
echo $CMD
execute_withlog $CMD
END_TIME=`timestamp`
stop-monitor $MONITOR_PID

gen_report ${START_TIME} ${END_TIME} ${SIZE}
show_bannar finish
leave_bench
