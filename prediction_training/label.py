import csv
import sys
import numpy as np
from sklearn import preprocessing

def label_features(input_file, labeled_file,  do_shuffle):
	
	X = read_file(input_file) 

	isLabel = X[0]
	X = label(isLabel, X[1:])
	print "Dataset size ",len(X)
 
	# shuffle dataset
	if do_shuffle:
		np.random.shuffle(X)

	write_file(labeled_file, X)
	return isLabel

def read_file(input_file):
	fin = open(input_file,'r');
        flag = 1
        X = []
        for row in csv.reader(fin):
                if flag==1:
                        X.append(row)
                else :
                        flag = 1
        fin.close()	
	return X

def label(isLabel, X):
	Xzipped = zip(*X)
        le = preprocessing.LabelEncoder()

        Xlabel = []
        for i in range(len(isLabel)):
                if isLabel[i] == "1":
                        le.fit(Xzipped[i])
                        Xlabel.append(le.transform(Xzipped[i]))
                else:
                        Xlabel.append(Xzipped[i])
        X = zip(*Xlabel)
        return X

def write_file(labeled_file, results):
	fout = open(labeled_file,'wb')
        writer = csv.writer(fout)
        writer.writerows(results)
