# Dataset

## Naming Rule

### Raw Data

Raw data, JSON file:

```bash
log.${APP}.${VM_COUNT}${VM_SIZE}.json
E.g.: log.wordcount.12L.json
```

### Preprocessed Data

1. Data only includes the features what we need in this project:

```bash
${APP}.${VM_COUNT}${VM_SIZE}.csv
E.g.: wordcount.12L.csv
```

2. ${VM_COUNT} is really added to the 4th attribute:

```bash
${APP}.${VM_COUNT}${VM_SIZE}.replaced.csv
E.g.: wordcount.12L.replaced.csv
```

3. Merge all data for the same application:

```bash
${APP}.all.replaced.csv
E.g.: wordcount.all.replaced.csv
```

4. Labeled data:

```bash
${APP}.labeled.csv
E.g.: wordcount.labeled.csv
```

## Features

* job_running_time(finishTime - startTime)
* job_state
* job_name
* instance_count
* instance_type
* mapreduce.job.reduces
* mapreduce.tasktracker.map.tasks.maximum
* mapreduce.tasktracker.reduce.tasks.maximum
* mapreduce.task.io.sort.mb
* mapreduce.task.io.sort.factor
* mapreduce.reduce.shuffle.parallelcopies
* mapreduce.reduce.shuffle.input.buffer.percent
* mapreduce.reduce.shuffle.merge.percent
* mapreduce.reduce.shuffle.memory.limit.percent
* mapreduce.map.sort.spill.percent
* mapreduce.reduce.input.buffer.percent
* mapreduce.reduce.merge.inmem.threshold
* mapreduce.job.reduce.slowstart.completedmaps
* mapreduce.jobtracker.handler.count
* mapreduce.tasktracker.http.threads
* mapreduce.map.cpu.vcores
* mapreduce.reduce.cpu.vcores
* mapreduce.map.memory.mb
* mapreduce.reduce.memory.mb
* yarn.app.mapreduce.am.resource.mb
* yarn.app.mapreduce.am.resource.cpu-vcores
* mapreduce.input.fileinputformat.split.minsize
* mapred.child.java.opts
* input file size
* file count
* num of word(1st period)
* num of line(1st period)
* num of word per line in avg(1st period)
* num of word per line in stddev(1st period)
* num of char per line in avg(1st period)
* num of char per line in stddev(1st period)
* num of char per word in avg(1st period)
* num of char per word in stddev(1st period)
* num of word(2nd period)
* num of line(2nd period)
* num of word per line in avg(2nd period)
* num of word per line in stddev(2nd period)
* num of char per line in avg(2nd period)
* num of char per line in stddev(2nd period)
* num of char per word in avg(2nd period)
* num of char per word in stddev(2nd period)
* num of word(3rd period)
* num of line(3rd period)
* num of word per line in avg(3rd period)
* num of word per line in stddev(3rd period)
* num of char per line in avg(3rd period)
* num of char per line in stddev(3rd period)
* num of char per word in avg(3rd period)
* num of char per word in stddev(3rd period)
