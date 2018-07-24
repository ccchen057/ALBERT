import numpy as np
from label import *
from preprocessing import *
from train import *
from test import *
from sklearn.externals import joblib

#initial
print "=========Initial========"
import argparse

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument("--i")
parser.add_argument("--l")
parser.add_argument("--o")
parser.add_argument("--BATCH_SIZE", default=200, type=int)
parser.add_argument("--NUM_LAYER", default=3, type=int)
parser.add_argument("--NUM_NEURAL", default=100, type=int)
parser.add_argument("--MAX_ITER", default=200, type=int)
parser.add_argument("--L_R_INIT", default=0.001, type=float)
parser.add_argument("--POWER_T", default=0.5, type=float)
parser.add_argument("--ALPHA", default=0.0001, type=float)
parser.add_argument("--SOLVER", default="adam", type=str)
args = parser.parse_args()

input_file = args.i
labeled_file = args.l
output_file = args.o
X = []
y = []
Ytarget = []

print "=========Label "+input_file+"========"
#Label text to number
label_features(input_file, labeled_file, True)

print "=========Read "+labeled_file+"========"
read_file(labeled_file, X, y, Ytarget)
tmp = np.array(X)
#X1 = tmp[:,2]

train_num = int(len(X) * 0.7)
total_num = int(len(X))
print "Dataset size ",total_num

#scaling each feature 
print "=========Scale========"
X,y = scale_values(X,y)

#feature selection with SelectKBest
#print "=========Feature Selection========"
#X = feature_select(X, y, 10)
#randomforest(X,y)
#PCA
#print "=========PCA========"
#X = pca(X, 5)

#training
print "=========Train========"
#clf, score = NN_train(X[:train_num], y[:train_num], args)
clfs, score = ALL_train(X[:train_num], y[:train_num], args)

#output training model to file
#joblib.dump(clf, output_file)

names = ["Nearest Neighbors", 
	"Linear SVM", 
	"RBF SVM", 
	#"Gaussian Process",
	"Decision Tree", 
	"Random Forest", 
	"AdaBoost",
	"Naive Bayes", 
	"Neural Net", 
	#"QDA"
]

for name, clf in zip(names, clfs):

	print "+++++++++" + name + "++++++++"
	#print "=========Test========"
	Ypredicted = predict(clf, X)
	#print zip(Ypredicted[train_num: total_num], y[train_num: total_num])[:10]

	#print "=========Result Display========"
	#error rate of test dataset
	#print "Total error rate:"
	error_list, accuracy = print_error(Ypredicted, Ytarget, range(train_num,total_num), True)
	#draw_boxplot(error_list,"box1",0,2)
	
	#training error
	#print "Training error rate:"
	#error_list, accuracy = print_error(Ypredicted, Ytarget, range(0,train_num), False)
	
	#print "=========Write "+output_file+"========"
	#write_file(output_file,np.percentile(Z, 75))

	#fout = open(output_file,'w')
	#fout.write(str(accuracy))
	#fout.close()
