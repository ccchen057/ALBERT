# ALBERT

## Offline Collect Data from HiBench on OpenStack

### Launch Cluster on OpenStack

1. Launch a cluster from Sahara on OpenStack
2. Associate floating IP to the master of the cluster
3. Login to the cluster

### Copy HiBench to the Cluster

1. Do it in local:

```bash
ssh-keygen -R 140.114.91.135
scp -i albert-key.pem -r HiBench albert-script ubuntu@140.114.91.135:.
```

2. Login to the cluster and do it as user **ubuntu**:

```bash
ssh -i albert-key.pem ubuntu@140.114.91.135
sudo apt-get install jq
sudo mv HiBench/ albert-script/ /home/hadoop/
sudo chown -R hadoop:hadoop /home/hadoop/HiBench/
sudo chown -R hadoop:hadoop /home/hadoop/albert-script/
sudo mkdir /home/hadoop/hadoop-log
sudo chown -R hadoop:hadoop /home/hadoop/hadoop-log/
```

### Collect Training Data

1. Login to the cluster and do it as user **hadoop**:

```bash
sudo su hadoop
cd ~/albert-script/prediction_training_data_generator/
```

2. Run script(number in *for* is the number of jobs you want to run)

```bash
for i in {1..100}; do bash run_wordcount.sh ; done
```

3. Rename the log file

```bash
mv ~/hadoop-log/hadoop.log ~/hadoop-log/log.wordcount.1L.json
```

And then copy the lof file to *ALBERT/data/*

### Profiling

1. Run the script

```bash
cd ~/albert-script/profiler/
bash auto.sh
```

### Something Already Hard Code

1. hdfs url: 

~/albert-script/HiBench/conf/hadoop.conf

```
hibench.hdfs.master       hdfs://${HDFS_IP}:${HDFS_PORT}
E.g.: hibench.hdfs.master       hdfs://192.168.100.53:9000
```

~/albert-script/profiler/auto.sh

```
echo "bash input_analyzer.sh hdfs://${HDFS_IP}:${HDFS_PORT}/HiBench/${i}/Input_${j} > ${i}_input_${j}.csv"
E.g.: echo "bash input_analyzer.sh hdfs://192.168.100.53:9000/HiBench/${i}/Input_${j} > ${i}_input_${j}.csv"
bash input_analyzer.sh hdfs://${HDFS_IP}:${HDFS_PORT}/HiBench/${i}/Input_${j} > ${app}_input_${j}.csv
E.g.: bash input_analyzer.sh hdfs://192.168.100.53:9000/HiBench/${i}/Input_${j} > ${app}_input_${j}.csv
```

2. Input file

```
hdfs://${HDFS_IP}:${HDFS_PORT}/HiBench/${APP}/Input_${ID}
E.g.: hdfs://192.168.100.53:9000/HiBench/Wordcount/Input_1
```

## Offline Training

### Classification Model

#### Preprocessing

1. Generate training data from execution logs

```bash
cd ~/albert-script/classification_training
bash genClassificationTrainingData.sh ../data/classification/log.invertedindex.json wordcount ../data/classification/log.invertedindex.csv
bash genClassificationTrainingData.sh ../data/classification/log.kmeans_classification.json kmeans ../data/classification/log.kmeans_classification.csv
bash genClassificationTrainingData.sh ../data/classification/log.kmeans_iterator.json kmeans ../data/classification/log.kmeans_iterator.csv
bash genClassificationTrainingData.sh ../data/classification/log.pagerank_stage1.json pagerank ../data/classification/log.pagerank_stage1.csv
bash genClassificationTrainingData.sh ../data/classification/log.pagerank_stage2.json pagerank ../data/classification/log.pagerank_stage2.csv
bash genClassificationTrainingData.sh ../data/classification/log.sort.json sort ../data/classification/log.sort.csv
bash genClassificationTrainingData.sh ../data/classification/log.terasort.json terasort ../data/classification/log.terasort.csv
bash genClassificationTrainingData.sh ../data/classification/log.trianglecount_triads.json bfs ../data/classification/log.trianglecount_triads.csv
bash genClassificationTrainingData.sh ../data/classification/log.trianglecount_triangles.json bfs ../data/classification/log.trianglecount_triangles.csv
bash genClassificationTrainingData.sh ../data/classification/log.wordcount.json wordcount ../data/classification/log.wordcount.csv
```

2. Merge files from different applications to 1 file and shuffle

```bash
cat ../data/classification/*.csv | shuf > ../data/classification/all.csv
```

3. Add label flags to the first line

```bash
bash addLabel.sh ../data/classification/all.csv
```

#### Training

```bash
python main.py --i ../data/classification/all.csv --l ../data/classification/all.labeled.csv --o ../model/classification
```

### Prediction Model

#### Preprocessing

1. Generate training data from execution logs

```bash
cd ~/albert-script/prediction_training
bash genPredictionTrainingData.sh ../data/log.wordcount.1L.json wordcount ../data/wordcount.1L.csv
bash genPredictionTrainingData.sh ../data/log.wordcount.3L.json wordcount ../data/wordcount.3L.csv
bash genPredictionTrainingData.sh ../data/log.wordcount.6L.json wordcount ../data/wordcount.6L.csv
bash genPredictionTrainingData.sh ../data/log.wordcount.12L.json wordcount ../data/wordcount.12L.csv
```

2. Set **VMCount** and **VMSize**
    By *sed*, the first number is **VMCount**, the second number is **VMSize**(1 for *Small*, 3 for *Medium*, 6 for *Large*)

```bash
cat wordcount.1L.csv | grep "SUCCEEDED" | sed 's/,0,,/,1,6,/g' > wordcount.1L.replaced.csv
cat wordcount.3L.csv | grep "SUCCEEDED" | sed 's/,0,,/,3,6,/g' > wordcount.3L.replaced.csv
cat wordcount.6L.csv | grep "SUCCEEDED" | sed 's/,0,,/,6,6,/g' > wordcount.6L.replaced.csv
cat wordcount.12L.csv | grep "SUCCEEDED" | sed 's/,0,,/,12,6,/g' > wordcount.12L.replaced.csv
```

3. Merge files from different **VMCount** to 1 file and shuffle

```bash
cat wordcount.*.replaced.csv | shuf | grep "word count" > wordcount.all.replaced.csv

cat pagerank.*.replaced.csv | shuf | grep "Pagerank_Stage1" > pagerank_1.all.replaced.csv
cat pagerank.*.replaced.csv | shuf | grep "Pagerank_Stage2" > pagerank_2.all.replaced.csv

cat trianglecount.*.replaced.csv | shuf | grep "triads" > trianglecount_1.all.replaced.csv
cat trianglecount.*.replaced.csv | shuf | grep "triangles" > trianglecount_2.all.replaced.csv

cat kmeans.*.replaced.csv | shuf | grep "Iterator" > kmeans_1.all.replaced.csv
cat kmeans.*.replaced.csv | shuf | grep "Classification" > kmeans_2.all.replaced.csv
```

#### Training

```bash
python main.py --i ../data/wordcount.all.replaced.csv --l ../data/wordcount.labeled.csv --o ../model/wordcount
python main.py --i ../data/terasort.all.replaced.csv --l ../data/terasort.labeled.csv --o ../model/terasort
python main.py --i ../data/kmeans_1.all.replaced.csv --l ../data/kmeans_1.labeled.csv --o ../model/kmeans_1
python main.py --i ../data/kmeans_2.all.replaced.csv --l ../data/kmeans_2.labeled.csv --o ../model/kmeans_2
python main.py --i ../data/pagerank_1.all.replaced.csv --l ../data/pagerank_1.labeled.csv --o ../model/pagerank_1
python main.py --i ../data/pagerank_2.all.replaced.csv --l ../data/pagerank_2.labeled.csv --o ../model/pagerank_2
python main.py --i ../data/trianglecount_1.all.replaced.csv --l ../data/trianglecount_1.labeled.csv --o ../model/trianglecount_1
python main.py --i ../data/trianglecount_2.all.replaced.csv --l ../data/trianglecount_2.labeled.csv --o ../model/trianglecount_2
```

## Optimization

### Start the optimizer deamon

```bash
cd ~/ALBERT/optimizer/
python app.py --m ../model/
```

### Job Level Optimization

Use curl to call optimizer deamon:

```bash
cd ~/albert-script/optimizer/
curl -X GET "http://0.0.0.0:9000" -d "${job_type},optimize_case/${job_input}_input_${CASE}.csv,${CONSTRAINT_FILE},${DEADLINE}" 2> /dev/null
```
```bash
cd ~/albert-script/optimizer/
curl -X GET "http://0.0.0.0:9000" -d "wordcount,optimize_case/wordcount_input_1.csv,constraint_sample.csv,100000000" 2> /dev/null
```

### System Level Optimization

#### Compile and run

1. Make

```bash
cd ~/albert-script/scheduler/
make
```

2. Execution

```bash
bin/scheduler $NUM_JOB $P $NUM_BIN $NUM_NODE_PER_BIN $IN_FILE $SAMPLE > $LOG_FILE &
```
```bash
bin/scheduler 100 1.0 4 12 jobs/designed_8.txt 1 > log.designed_8.txt &
```

3. Watch progress(file name: log.p_*)

```bash
bash viewProgress.sh
```

4. Get the dispatched results($FILE is the log file of scheduler)

```bash
bash getRectangles.sh $FILE > packed_result.csv
```

5. Visualize the packed result, use *genImg.m* and *genMov.m*

#### Workload

Workloads are in *~/albert-script/scheduler/jobs*.

In the file, each row represents 1 job.

There are 4 columns, which specify application id, input file id, estimated execution time and minimum node requirement.

##### Workload Generator

```bash
cd ~/ALBERT/scheduler/jobs
# Generate jobs
bash genJobs.sh $NUM_JOBS $ZIPF_RATIO $OUT_FILE
# Add minimum node requirement
# $RAND_RANGE is the range of minimum node requirement
# E.g.: if set 5, the minimum node requirement can be random number from [1, 5]
bash addMinNode.sh $FILE $NUM_BIG_JOB $RAND_RANGE
```
```bash
cd ~/ALBERT/scheduler/jobs
bash genJobs.sh 100 0 tmp.jobs.txt
bash addMinNode.sh tmp.jobs.txt 20 5 > jobs.txt
```

##### Workload 1

1. 100job_8.txt: workload1 in the thesis
2. 100job_random.txt: workload1, but without sorting by estimated execution time
3. 100job_8.txt: workload1, with minimum node requirement set to 8 Large nodes

##### Workload 2

1. designed.txt: workload2 in the thesis
2. designed_random.txt: workload2, but without sorting by estimated execution time
3. designed_8.txt: workload2, with minimum node requirement set to 8 Large nodes
