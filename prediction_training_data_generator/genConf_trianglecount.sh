#/bin/bash

WORKLOAD_DIR=$1
workload=$(echo ${WORKLOAD_DIR} | cut -d '/' -f 8)

function genConf() {
	if [ ${line:0:1} = "#" ]; then
		return 0
	fi
	conf=$(echo $1 | cut -d ' ' -f 1)
	begin=$(echo $1 |cut -d ' ' -f 2)
	end=$(echo $1 |cut -d ' ' -f 3)
	space=$(echo $1 |cut -d ' ' -f 4)
	text=$(echo $1 |cut -d ' ' -f 5)
	random=$(od -vAn -N4 -tu4  /dev/urandom)
	
	result=$(echo "$random%(($end-$begin)/$space+1)*$space+$begin" | bc)
	if [ "$text" != "" ]; then
		result=$(echo $text | sed "s/BLANK/$result/g")
	fi
	echo "-D $conf=$result"
	echo "-D $conf=$result" >> ${workload}.para
}

echo -n "" >  ${workload}.para

while IFS='' read -r line || [[ -n "$line" ]]; do
	genConf "$line"
done < "${workload}.conf"
