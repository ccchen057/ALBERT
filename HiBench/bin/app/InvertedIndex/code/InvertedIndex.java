package simple_InvertedIndex;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.conf.Configured;

public class InvertedIndex extends Configured implements Tool{
    @Override
    public int run(String[] args) throws Exception {
        Configuration conf = this.getConf();;
        
        Job job = Job.getInstance(conf, "InvertedIndex");
        job.setJarByClass(InvertedIndex.class);
        
        
        // set the class of each stage in mapreduce
        job.setMapperClass(InvertedMapper.class);
        job.setCombinerClass(InvertedCombiner.class);
        job.setReducerClass(InvertedReducer.class);
        
        job.setInputFormatClass(BinaryInputFormat.class);
        // set the output class of Mapper and Reducer
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(Text.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);
        job.setOutputFormatClass(BinaryOutputFormat.class);
        // set the number of reducer
        //job.setNumReduceTasks(1);
        
        // add input/output path
        TextInputFormat.addInputPath(job, new Path(args[args.length-2]));
        FileOutputFormat.setOutputPath(job, new Path(args[args.length-1]));
        
        return job.waitForCompletion(true) ? 0 : 1;
    }
	
    Configuration conf;
   
    @Override
    public Configuration getConf() {
        // TODO Auto-generated method stub
        return conf;
    }

    @Override
    public void setConf(Configuration arg0) {
        // TODO Auto-generated method stub
        this.conf=arg0;
    } 

    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new Configuration(), new InvertedIndex(), args);
        System.exit(res);
    }
}
