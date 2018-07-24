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
	-Dmapreduce.job.reduces=20 -Dmapreduce.tasktracker.map.tasks.maximum=10 -Dmapreduce.tasktracker.reduce.tasks.maximum=6 -Dmapreduce.task.io.sort.mb=144 -Dmapreduce.task.io.sort.factor=69 -Dmapreduce.reduce.shuffle.parallelcopies=6 -Dmapreduce.reduce.shuffle.input.buffer.percent=0.7685380256423138 -Dmapreduce.reduce.shuffle.merge.percent=0.5851720596480905 -Dmapreduce.reduce.shuffle.memory.limit.percent=0.2706052609231003 -Dmapreduce.map.sort.spill.percent=0.8443094147943813 -Dmapreduce.reduce.input.buffer.percent=0.15348982035078695 -Dmapreduce.reduce.merge.inmem.threshold=1167 -Dmapreduce.job.reduce.slowstart.completedmaps=0.9803310510967068 -Dmapreduce.jobtracker.handler.count=49 -Dmapreduce.tasktracker.http.threads=54 -Dmapreduce.map.cpu.vcores=2 -Dmapreduce.reduce.cpu.vcores=4 -Dmapreduce.map.memory.mb=1102 -Dmapreduce.reduce.memory.mb=1672 -Dyarn.app.mapreduce.am.resource.mb=512 -Dyarn.app.mapreduce.am.resource.cpu-vcores=4 -Dmapreduce.input.fileinputformat.split.minsize=0 -Dmapred.child.java.opts=397 \
	${INPUT_HDFS}_3 ${OUTPUT_HDFS}
END_TIME=`timestamp`

gen_report ${START_TIME} ${END_TIME} ${SIZE}
show_bannar finish
leave_bench
