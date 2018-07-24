#!/bin/bash

for i in $(echo "Wordcount Terasort Sort Invertedindex BFS Pagerank Kmeans"); do
	for j in 1 2 3 4; do
		echo "bash input_analyzer.sh hdfs://hdfs:9000/HiBench/${i}/Input_${j} > predict_case/${i}_input_${j}.csv"
		app=$(echo "$i" | tr A-Z a-z) 
		bash input_analyzer.sh hdfs://hdfs:9000/HiBench/${i}/Input_${j} > predict_case/${app}_input_${j}.csv
	done
done
