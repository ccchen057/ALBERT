# You do not have to modify this file unless you have multiple packages in your MR java code
rm -r class/*
#javac -classpath lib/hadoop-common-2.7.2.jar:lib/hadoop-mapreduce-client-core-2.7.2.jar -d class code/*
javac -classpath /opt/hadoop/share/hadoop/common/hadoop-common-2.7.1.jar:/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.1.jar -d class code/*
jar -cvf InvertedIndex.jar -C class/ .
