# Do not uncomment these lines to directly execute the script
# Modify the path to fit your need before using this script
#hdfs dfs -rm -r /user/TA/WordCount/Output/
#hadoop jar WordCount.jar wordcount.WordCount /user/shared/WordCount/Input /user/TA/WordCount/Output
#hdfs dfs -cat /user/TA/WordCount/Output/part-*

/opt/hadoop/bin/hadoop fs -rm -r hdfs://hdfs:9000/HiBench/Trianglecount/Output
/opt/hadoop/bin/hadoop jar TriangleCount.jar triangleCounting.TriangleCounter hdfs://hdfs:9000/HiBench/BFS/Input_1 hdfs://hdfs:9000/HiBench/Trianglecount/Output
#hdfs dfs -cp -f InvertedIndex/Output/part-* Retrieval/Input/Output_invertedIndex
