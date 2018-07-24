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
root_dir=${current_dir}/../../../../..
workload_config=${root_dir}/conf/workloads/websearch/pagerank.conf
. "${root_dir}/bin/functions/load-bench-config.sh"

enter_bench HadoopPagerank ${workload_config} ${current_dir}
show_bannar start

rmr-hdfs $OUTPUT_HDFS || true

SIZE=`dir_size $INPUT_HDFS`

if [ $BLOCK -eq 0 ]
then
    NUM_REDS=102
    OPTION="
        -Dmapred.child.java.opts=-Xmx799m \
        -Dmapreduce.input.fileinputformat.split.minsize=71016448 \
        -Dyarn.app.mapreduce.am.resource.cpu-vcores=3 \
        -Dyarn.app.mapreduce.am.resource.mb=1920 \
        -Dmapreduce.reduce.memory.mb=1408 \
        -Dmapreduce.map.memory.mb=2048 \
        -Dmapreduce.reduce.cpu.vcores=4 \
        -Dmapreduce.map.cpu.vcores=2 \
        -Dmapreduce.tasktracker.http.threads=60 \
        -Dmapreduce.jobtracker.handler.count=70 \
        -Dmapreduce.job.jvm.numtasks= \
        -Dmapreduce.job.reduce.slowstart.completedmaps=.40 \
        -Dmapreduce.reduce.merge.inmem.threshold=1600 \
        -Dmapreduce.reduce.input.buffer.percent=.8 \
        -Dmapreduce.map.sort.spill.percent=.5 \
        -Dmapreduce.reduce.shuffle.memory.limit.percent=.3 \
        -Dmapreduce.reduce.shuffle.merge.percent=.50 \
        -Dmapreduce.reduce.shuffle.input.buffer.percent=.7 \
        -Dmapreduce.reduce.shuffle.parallelcopies=5 \
        -Dmapreduce.task.io.sort.factor=50 \
        -Dmapreduce.task.io.sort.mb=150 \
        -Dmapreduce.tasktracker.reduce.tasks.maximum=12 \
        -Dmapreduce.tasktracker.map.tasks.maximum=18 \
        -Dmapreduce.job.reduces=102 \
	${INPUT_HDFS}_1/edges ${OUTPUT_HDFS} \
	${PAGES} \
	${NUM_REDS} \
	${NUM_ITERATIONS} \
	nosym new
	"
else
    NUM_REDS=102
    OPTION="
        -Dmapred.child.java.opts=-Xmx799m \
        -Dmapreduce.input.fileinputformat.split.minsize=71016448 \
        -Dyarn.app.mapreduce.am.resource.cpu-vcores=3 \
        -Dyarn.app.mapreduce.am.resource.mb=1920 \
        -Dmapreduce.reduce.memory.mb=1408 \
        -Dmapreduce.map.memory.mb=2048 \
        -Dmapreduce.reduce.cpu.vcores=4 \
        -Dmapreduce.map.cpu.vcores=2 \
        -Dmapreduce.tasktracker.http.threads=60 \
        -Dmapreduce.jobtracker.handler.count=70 \
        -Dmapreduce.job.jvm.numtasks= \
        -Dmapreduce.job.reduce.slowstart.completedmaps=.40 \
        -Dmapreduce.reduce.merge.inmem.threshold=1600 \
        -Dmapreduce.reduce.input.buffer.percent=.8 \
        -Dmapreduce.map.sort.spill.percent=.5 \
        -Dmapreduce.reduce.shuffle.memory.limit.percent=.3 \
        -Dmapreduce.reduce.shuffle.merge.percent=.50 \
        -Dmapreduce.reduce.shuffle.input.buffer.percent=.7 \
        -Dmapreduce.reduce.shuffle.parallelcopies=5 \
        -Dmapreduce.task.io.sort.factor=50 \
        -Dmapreduce.task.io.sort.mb=150 \
        -Dmapreduce.tasktracker.reduce.tasks.maximum=12 \
        -Dmapreduce.tasktracker.map.tasks.maximum=18 \
        -Dmapreduce.job.reduces=102 \
	${OUTPUT_HDFS} \
	${PAGES} \
	${NUM_REDS} \
	${NUM_ITERATIONS} \
	${BLOCK_WIDTH}
	"
fi

MONITOR_PID=`start-monitor`
START_TIME=`timestamp`

# run bench
if [ $BLOCK -eq 0 ]
then
    run-hadoop-job ${PEGASUS_JAR} pegasus.PagerankNaive $OPTION
else
    run-hadoop-job ${PEGASUS_JAR} pegasus.PagerankInitVector  ${OUTPUT_HDFS}/pr_initvector ${PAGES} ${NUM_REDS}
    rmr-hdfs ${OUTPUT_HDFS}/pr_input

    rmr-hdfs ${OUTPUT_HDFS}/pr_iv_block
    run-hadoop-job ${PEGASUS_JAR} pegasus.matvec.MatvecPrep  ${OUTPUT_HDFS}/pr_initvector ${OUTPUT_HDFS}/pr_iv_block ${PAGES} ${BLOCK_WIDTH} ${NUM_REDS} s makesym
    rmr-hdfs ${OUTPUT_HDFS}/pr_initvector

    rmr-hdfs ${OUTPUT_HDFS}/pr_edge_colnorm
    run-hadoop-job ${PEGASUS_JAR} pegasus.PagerankPrep  ${INPUT_HDFS}_1/edges ${OUTPUT_HDFS}/pr_edge_colnorm ${NUM_REDS} makesym

    rmr-hdfs ${OUTPUT_HDFS}/pr_edge_block
    run-hadoop-job ${PEGASUS_JAR} pegasus.matvec.MatvecPrep  ${OUTPUT_HDFS}/pr_edge_colnorm ${OUTPUT_HDFS}/pr_edge_block ${PAGES} ${BLOCK_WIDTH} ${NUM_REDS} null nosym
    rmr-hdfs ${OUTPUT_HDFS}/pr_edge_colnorm

    run-hadoop-job ${PEGASUS_JAR} pegasus.PagerankBlock ${OPTION}
fi

END_TIME=`timestamp`
stop-monitor $MONITOR_PID

gen_report ${START_TIME} ${END_TIME} ${SIZE}
show_bannar finish
leave_bench

