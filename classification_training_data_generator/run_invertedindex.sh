#/bin/bash

function echoProgress() {
	echo -e "\E[0;94m$1\E[0m"
}

HIBENCH_DIR=~/HiBench
WORKLOAD_DIR=${HIBENCH_DIR}/bin/workloads/micro/invertedindex
LOG_OUTPUT=~/hadoop-log/hadoop.log
#LOG_OUTPUT=/dev/null
INPUTDIR_RANGE=1
COMMENT="inverted index classification"

echoProgress "Initialization"
	workload=$(echo ${WORKLOAD_DIR} | cut -d '/' -f 8)
	echo "Workload: $workload"
if [ $?=="0" ] ; then echo "Done"; fi

echoProgress "Generate configurations"
	#bash genConf_${workload}.sh ${WORKLOAD_DIR}
if [ $?=="0" ] ; then echo "Done"; fi

echoProgress "Set configurations"
	bash setConf_${workload}.sh ${WORKLOAD_DIR}
if [ $?=="0" ] ; then echo "Done"; fi

echoProgress "Set Input directory"
	bash setInput.sh ${WORKLOAD_DIR} $INPUTDIR_RANGE
if [ $?=="0" ] ; then echo "Done"; fi

echoProgress "Running..."
	bash ${WORKLOAD_DIR}/hadoop/run.sh
if [ $?=="0" ] ; then echo "Done"; fi

echoProgress "Get job ID"
	LOG_FILE=${HIBENCH_DIR}/report/${workload}/hadoop/bench.log
	jobid=$(cat ${LOG_FILE} | grep "Running job:" | awk -F' ' '{printf("%s ",$7) }')
	echo "Job ID: $jobid"
if [ $?=="0" ] ; then echo "Done"; fi

for i in $jobid ; do

	echoProgress "Get Hadoop log ($i)"	
		hadoop_log=$(bash getLog.sh $i)
	if [ $?=="0" ] ; then echo "Done"; fi
	
	echoProgress "Get Ceilometer log ($i)"
		start_time=$(echo $hadoop_log | jq .job.startTime)
		echo "Start time: $start_time"
		finish_time=$(echo $hadoop_log | jq .job.finishTime)
		echo "Finish time: $finish_time"
		metric_log=$(bash getMetric.sh $start_time $finish_time)
		data=$(echo $hadoop_log $metric_log | jq -s add)
	if [ $?=="0" ] ; then echo "Done"; fi

	echoProgress "Generate metadata ($i)"
		info=$(bash genInfo.sh "$data" "$COMMENT")
	if [ $?=="0" ] ; then echo "Done"; fi
	
	data=$(echo $info $data | jq -s add)
	echo $data >> $LOG_OUTPUT
done
