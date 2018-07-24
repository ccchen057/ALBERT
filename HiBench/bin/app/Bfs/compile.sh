# You do not have to modify this file unless you have multiple packages in your MR java code
rm -r class/*
javac -classpath lib/hadoop-common-2.7.2.jar:lib/hadoop-mapreduce-client-core-2.7.2.jar:lib/commons-logging-1.2.jar -d class code/*
jar -cvf Bfs.jar -C class/ .
