#!/bin/bash

for i in {0..10}; do

	p=$(echo "0.1*$i" | bc)
	#echo "$p"
	./scheduler 200 $p 4 12 ~/albert-script-0426/scheduler/gen_case/new/job_8app.1_00.txt 1 > log.p_${p}-zipf_1.00.txt &

done
