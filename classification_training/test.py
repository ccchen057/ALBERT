from sklearn.neural_network import MLPRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.svm import SVR
#import matplotlib.pyplot as plt
import numpy as np

def predict(clf, X):
	#print "Testing start..."
	Ypredicted = clf.predict(X)

	return Ypredicted

def print_error(Ypredicted, Ytarget, index, detailed):
	#print "----------------------"
	target = np.array([Ytarget[i] for i in index])
	predicted = np.array([Ypredicted[i] for i in index])
	error_list = abs((predicted - target))
	error_count = np.count_nonzero(error_list)
	#print "Dataset size: ", len(index)
	#print "Error count: ", error_count
	print "Accuracy: ", (float)(len(index)-error_count)/len(index)
	
	#for i in range(1,len(Ytarget)):
	#	if Ytarget[i]-Ypredicted[i] != 0:
	#		print Ytarget[i], Ypredicted[i]

	#print "----------------------\n"	
	return error_list, (float)(len(index)-error_count)/len(index) 
	
def get_percentile(error_list,n):
	print str(n)+"%: ",
	print np.percentile(error_list, n)

def error_threshold(error_list,t):
	print "#Error > ",t,":",
        print sum(1 for i in error_list if i >t) 

def draw_boxplot(error_list,filename,y_min,y_max):
	fig = plt.figure()
	plt.boxplot(error_list)
	x1, x2, y1, y2 = plt.axis()
	plt.axis([x1, x2, y_min, y_max])
	plt.savefig(filename)

def write_file(output_file,results):
	f = open(output_file, 'w')
	f.write(str(results))
	f.close()
