package simple_InvertedIndex;

import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;

public class BinaryInputFormat extends SequenceFileInputFormat<BytesWritable,BytesWritable> {

}
