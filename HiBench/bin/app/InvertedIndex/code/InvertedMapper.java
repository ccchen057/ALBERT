package simple_InvertedIndex;

import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;  
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.InputSplit;
import java.util.Random;

public class InvertedMapper extends Mapper<Text, Text, Text,Text> {
	Text keyInfo = new Text();      // Save Term+FileName  
   	Text valueinfo = new Text("1");
	String filename;	
	
//	@Override
	/*protected void setup(Context context) throws IOException, InterruptedException {
    		FileSplit fileSplit = (FileSplit) context.getInputSplit();
    		//filename = fsFileSplit.getPath().getName();
		//filename = context.getConfiguration().get("map.input.file");
		//filename = ((FileSplit) context.getInputSplit()).getPath().getName();
		Random ran = new Random();
		filename = "file_"+ String.valueOf(ran.nextInt(7)+1);
  	}*/

    public void map(Text key, Text value, Context context) throws IOException, InterruptedException {        
        StringTokenizer iter = new StringTokenizer(value.toString());  
	filename = "#"+((FileSplit) context.getInputSplit()).getPath().getName(); 
        
        
	while(iter.hasMoreTokens())  
        {   
	    String keyname = iter.nextToken()+filename;
            
            keyInfo.set(keyname); 
	    //valueinfo.set("1"); 
            context.write(keyInfo, valueinfo);  
        }  
    }  
    
}
