#!/bin/bash

if [ "$1" = "" ]; then
        echo "usage: sh getresults.sh APP"
        exit 0;
fi



for (( i=0; i < 20; i++ )); do
	echo "${i} : python main.py --i log.${1}.csv --l log.${1}.labeled.csv --o result.sort --NUM_LAYER 10 --NUM_NEURAL 100 --SOLVER lbfgs"
	python main.py --i log.${1}.csv --l log.${1}.labeled.csv --o result.sort --NUM_LAYER 10 --NUM_NEURAL 100 --SOLVER lbfgs > tmp

	echo $( cat tmp | grep "10%" | cut -d: -f2) >> results/${1}_err10 
	echo $( cat tmp | grep "mean"| cut -d: -f2) >> results/${1}_err_mean
	echo $( cat tmp | grep "90%" | cut -d: -f2) >> results/${1}_err90
done
