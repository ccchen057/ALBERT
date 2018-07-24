package simple_InvertedIndex;

import java.io.IOException;

import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Reducer;

public class InvertedCombiner extends Reducer<Text,Text,Text,Text>  {
	Text info = new Text();  
    	Text key1 = new Text();
    @Override  
    public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {  
        // 計算詞頻  
        int sum = 0;  

        	for(Text value:values) sum += 1;  	
		String[] items = key.toString().split("#");  
        
		info.set(items[1]+":"+String.valueOf(sum)); 
        	context.write( key, info); 
    }  
}
