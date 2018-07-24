#/bin/bash

if [ "$1" = "" ]; then
        echo "usage: sh input_analyzer.sh INPUT_PATH"
        exit 0;
fi

INPUT_PATH=$1

input_info=$(/opt/hadoop/bin/hadoop fs -ls -R $INPUT_PATH | sort -n -k 5)

# input size
echo "${input_info}" | awk -F' ' '{if($5>0){print $5}}' | awk '{s+=$1} END {printf "%.0f", s}'
echo -n ","
# file count
echo "${input_info}" | awk -F' ' '{if($5>0){print $5}}' | wc -l | tr -d '\n'
echo -n ","

# file size > 1KB
valid_file_info=$(echo "${input_info}" | awk -F' ' '{if($5>1024){print $0}}')
valid_file_num=$(echo "${valid_file_info}" | wc -l)
for i in 25 50 75; do
	index=$(echo $(((valid_file_num-1)*i/100+1)))
	#echo $index
	file_path=$(echo "${valid_file_info}" | sed -n "${index}p" | awk -F' ' '{print $8}')
	data=$(/opt/hadoop/bin/hadoop fs -tail $file_path)
	#echo "$data"
		
	# #word
	echo -e "$data" | wc -w | tr -d '\n' 
	echo -n ","
	# #line
	echo -e "$data" | wc -l | tr -d '\n'
	echo -n ","
	
	num=""	
	while read line; do
	        num=$num$(echo "$line" | wc -w)"\n"
	done <<< "$(echo "$data")"
	# word/line avg
	echo -e "${num:0:-2}" | awk -F'\n' '{s+=$1} END {printf s/NR}'
	echo -n ","
	# word/line stddev
	echo -e "${num:0:-2}" | awk -F'\n' '{sum+=$1; sumsq+=$1*$1}END{printf sqrt(sumsq/NR - (sum/NR)**2)}'
	echo -n ","
	
	num=""	
	while read line; do
	        num=$num$(echo "$line" | wc -m)"\n"
	done <<< "$(echo "$data")"
	# char/line avg
	echo -e "${num:0:-2}" | awk -F'\n' '{s+=$1} END {printf s/NR}'
	echo -n ","
	# char/line stddev
	echo -e "${num:0:-2}" | awk -F'\n' '{sum+=$1; sumsq+=$1*$1}END{printf sqrt(sumsq/NR - (sum/NR)**2)}'
	echo -n ","
	
	num=""	
	for word in $data; do
	        num=$num$(echo -n "$word" | wc -m)"\n"
	done
	# char/word avg
	echo -e "${num:0:-2}" | awk -F'\n' '{s+=$1} END {printf s/NR}'
	echo -n ","
	# char/word stddev
	echo -e "${num:0:-2}" | awk -F'\n' '{sum+=$1; sumsq+=$1*$1}END{printf sqrt(sumsq/NR - (sum/NR)**2)}'
	echo -n ","
done
