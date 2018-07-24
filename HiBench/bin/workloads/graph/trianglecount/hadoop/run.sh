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
workload_config=${root_dir}/conf/workloads/graph/trianglecount.conf
. "${root_dir}/bin/functions/load-bench-config.sh"

enter_bench HadoopWordcount ${workload_config} ${current_dir}
show_bannar start

rmr-hdfs $OUTPUT_HDFS || true

SIZE=`dir_size $INPUT_HDFS`
START_TIME=`timestamp`
run-hadoop-job /home/hadoop/HiBench/bin/app/TriangleCount/TriangleCount.jar triangleCounting.TriangleCounter \
    -D mapreduce.job.maps=${NUM_MAPS} \
    -D mapreduce.job.reduces=${NUM_REDS} \
    -D mapreduce.inputformat.class=org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat \
    -D mapreduce.outputformat.class=org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat \
    -D mapreduce.job.inputformat.class=org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat \
    -D mapreduce.job.outputformat.class=org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat \
    -Dmapreduce.job.reduces=50 \
    -Dmapreduce.tasktracker.map.tasks.maximum=12 \
    -Dmapreduce.tasktracker.reduce.tasks.maximum=12 \
    -Dmapreduce.task.io.sort.mb=110 \
    -Dmapreduce.task.io.sort.factor=90 \
    -Dmapreduce.reduce.shuffle.parallelcopies=10 \
    -Dmapreduce.reduce.shuffle.input.buffer.percent=.6 \
    -Dmapreduce.reduce.shuffle.merge.percent=.65 \
    -Dmapreduce.reduce.shuffle.memory.limit.percent=.5 \
    -Dmapreduce.map.sort.spill.percent=.7 \
    -Dmapreduce.reduce.input.buffer.percent=.2 \
    -Dmapreduce.reduce.merge.inmem.threshold=1500 \
    -Dmapreduce.job.reduce.slowstart.completedmaps=.75 \
    -Dmapreduce.jobtracker.handler.count=60 \
    -Dmapreduce.tasktracker.http.threads=60 \
    -Dmapreduce.map.cpu.vcores=1 \
    -Dmapreduce.reduce.cpu.vcores=2 \
    -Dmapreduce.map.memory.mb=1536 \
    -Dmapreduce.reduce.memory.mb=1280 \
    -Dyarn.app.mapreduce.am.resource.mb=1792 \
    -Dyarn.app.mapreduce.am.resource.cpu-vcores=3 \
    -Dmapred.child.java.opts=-Xmx528m \
    ${INPUT_HDFS}_2 ${OUTPUT_HDFS} 
END_TIME=`timestamp`

gen_report ${START_TIME} ${END_TIME} ${SIZE}
show_bannar finish
leave_bench
