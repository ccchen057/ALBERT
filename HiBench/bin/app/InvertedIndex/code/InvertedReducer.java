package simple_InvertedIndex;

import java.io.IOException;

import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Reducer;

public class InvertedReducer extends Reducer<Text,Text,Text,Text> {
	Text result = new Text();  
      
    public void reduce(Text key, Iterable<Text> values, Context context)  throws IOException, InterruptedException {  
        StringBuffer fileList = new StringBuffer();  
        int sum = 0;
	String[] items = key.toString().split("#"); 
        for(Text value:values)  
        {  
	    fileList.append(value.toString());
       }  
        result.set(fileList.toString());  
	key.set(items[0]);
        context.write(key, result);  
    }  
}
