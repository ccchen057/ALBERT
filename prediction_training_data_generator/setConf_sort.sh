#/bin/bash

WORKLOAD_DIR=$1
RUN_FILE=${WORKLOAD_DIR}/hadoop/run.sh
workload=$(echo ${WORKLOAD_DIR} | cut -d '/' -f 8)

function insertConf() {
	conf=$(echo $1 | cut -d'=' -f1)
	value=$(echo $1 | cut -d'=' -f2)
	if [[ "$conf" == "mapreduce.job.reduces" ]]; then
		replaced='-'
	else
		replaced='${NUM_REDS}'
		sed -i "s/$replaced/$value/g" ${RUN_FILE}
	fi
}

if [ ! -f ${RUN_FILE}.ori ]; then
	cp ${RUN_FILE} ${RUN_FILE}.ori
fi

/bin/cp -f ${RUN_FILE}.ori ${RUN_FILE}

while IFS='' read -r line || [[ -n "$line" ]]; do
	insertConf "$line"
done < "${workload}.para"
