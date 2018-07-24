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
workload_config=${root_dir}/conf/workloads/micro/terasort.conf
. "${root_dir}/bin/functions/load-bench-config.sh"

enter_bench HadoopTerasort ${workload_config} ${current_dir}
show_bannar start

rmr-hdfs $OUTPUT_HDFS || true

SIZE=`dir_size $INPUT_HDFS`
START_TIME=`timestamp`
run-hadoop-job ${HADOOP_EXAMPLES_JAR} terasort \
    -D mapreduce.job.reduces=1 \
    -Dmapreduce.job.reduces=1 \
    -Dmapreduce.tasktracker.map.tasks.maximum=2 \
    -Dmapreduce.tasktracker.reduce.tasks.maximum=2 \
    -Dmapreduce.task.io.sort.mb=100 \
    -Dmapreduce.task.io.sort.factor=10 \
    -Dmapreduce.reduce.shuffle.parallelcopies=5 \
    -Dmapreduce.reduce.shuffle.input.buffer.percent=0.7 \
    -Dmapreduce.reduce.shuffle.merge.percent=.66 \
    -Dmapreduce.reduce.shuffle.memory.limit.percent=.25 \
    -Dmapreduce.map.sort.spill.percent=.8 \
    -Dmapreduce.reduce.input.buffer.percent=0 \
    -Dmapreduce.reduce.merge.inmem.threshold=1000 \
    -Dmapreduce.job.reduce.slowstart.completedmaps=.05 \
    -Dmapreduce.jobtracker.handler.count=10 \
    -Dmapreduce.tasktracker.http.threads=40 \
    -Dmapreduce.map.cpu.vcores=1 \
    -Dmapreduce.reduce.cpu.vcores=1 \
    -Dmapreduce.map.memory.mb=1024 \
    -Dmapreduce.reduce.memory.mb=1024 \
    -Dyarn.app.mapreduce.am.resource.mb=512 \
    -Dyarn.app.mapreduce.am.resource.cpu-vcores=1 \
    -Dmapred.child.java.opts=-Xmx200m \
    ${INPUT_HDFS}_3 ${OUTPUT_HDFS}
END_TIME=`timestamp`

gen_report ${START_TIME} ${END_TIME} ${SIZE}
show_bannar finish
leave_bench
