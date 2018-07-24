#/bin/bash

WORKLOAD_DIR=$1
RUN_FILE=${WORKLOAD_DIR}/hadoop/run.sh
workload=$(echo ${WORKLOAD_DIR} | cut -d '/' -f 8)

RANGE=$2

begin=1
end=$RANGE
space=1
random=$(od -vAn -N4 -tu4  /dev/urandom)
result=$(echo "$random%(($end-$begin)/$space+1)*$space+$begin" | bc)

replaced='${INPUT_HDFS}'
new=$(echo '${INPUT_HDFS}')$(echo "_$result")

sed -i "s/$replaced/$new/g" ${RUN_FILE}
