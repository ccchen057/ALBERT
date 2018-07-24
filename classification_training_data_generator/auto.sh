#!/bin/bash

for i in $(echo "wordcount terasort sort invertedindex pagerank kmeans trianglecount"); do
	echo "bash run_${i}.sh"
	bash run_${i}.sh
done
