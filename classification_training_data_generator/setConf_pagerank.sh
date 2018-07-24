#/bin/bash

WORKLOAD_DIR=$1
RUN_FILE=${WORKLOAD_DIR}/hadoop/run.sh
workload=$(echo ${WORKLOAD_DIR} | cut -d '/' -f 8)

function insertConf() {
	replaced='OPTION="'
	sed -i "/$replaced/a\        $1 \\\\" ${RUN_FILE}
	
	para=$(echo $1 | cut -d' ' -f2 | cut -d'=' -f1)
	if [ "$para" = "mapreduce.job.reduces" ]; then
		value=$(echo $1 | cut -d'=' -f2)
		replaced='OPTION="'
		sed -i "/$replaced/i\    NUM_REDS=$value\\" ${RUN_FILE}
	fi
}

if [ ! -f ${RUN_FILE}.ori ]; then
	cp ${RUN_FILE} ${RUN_FILE}.ori
fi

/bin/cp -f ${RUN_FILE}.ori ${RUN_FILE}

while IFS='' read -r line || [[ -n "$line" ]]; do
	insertConf "$line"
done < "${workload}.para"
