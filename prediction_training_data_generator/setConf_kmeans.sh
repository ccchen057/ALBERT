#/bin/bash

WORKLOAD_DIR=$1
RUN_FILE=${WORKLOAD_DIR}/hadoop/run.sh
workload=$(echo ${WORKLOAD_DIR} | cut -d '/' -f 8)

function insertConf() {
	replaced='${OUTPUT_HDFS}'
	sed -i "/$replaced/i\        $1 \\\\" ${RUN_FILE}
}

if [ ! -f ${RUN_FILE}.ori ]; then
	cp ${RUN_FILE} ${RUN_FILE}.ori
fi

/bin/cp -f ${RUN_FILE}.ori ${RUN_FILE}

while IFS='' read -r line || [[ -n "$line" ]]; do
	insertConf "$line"
done < "${workload}.para"
