package simple_InvertedIndex;

import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;

public class BinaryOutputFormat extends SequenceFileOutputFormat<BytesWritable,BytesWritable> {

}
