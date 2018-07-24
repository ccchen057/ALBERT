#!/bin/bash

for i in {0..10}; do

	p=$(echo "0.1*$i" | bc)

	#echo -n "$p "

	bash calScore.sh log.p_${p}-zipf_${1}.txt

done
