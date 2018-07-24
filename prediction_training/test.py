from sklearn.neural_network import MLPRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.svm import SVR
#import matplotlib.pyplot as plt
import numpy as np

def predict(clf, X):
        print "Testing start..."
        Ypredicted = clf.predict(X)
	#print Ypredicted

        #print "Scale back..."
        #Ypredicted = scalerY.inverse_transform(Ypredicted)
	#print Ypredicted

        return Ypredicted

def Keras_predict(clf, X):
        print "Testing start..."
        Ypredicted = clf.predict(X)
	Ypredicted = Ypredicted.ravel()

        #print "Scale back..."
        #Ypredicted = scalerY.inverse_transform(Ypredicted)
        
        
	return Ypredicted

def print_error(Ypredicted, Ytarget, index, detailed):
	print "----------------------"
        target = np.array([Ytarget[i] for i in index])
        predicted = np.array([Ypredicted[i] for i in index])
        error_list = abs((predicted - target)/target)
        
	print "Dataset size: ", len(index)
        get_percentile(error_list, 0) #min

        if detailed == True :
		get_percentile(error_list, 10) #Q1
                get_percentile(error_list, 25) #Q1
                get_percentile(error_list, 50) #Q2
                get_percentile(error_list, 75) #Q3
                get_percentile(error_list, 90) #90%
                get_percentile(error_list, 95) #95%

        get_percentile(error_list, 100) #max
        print "mean: ",
        print np.mean(error_list)
        error_threshold(error_list,1)
        print "----------------------\n"
	
	
        return error_list, np.mean(error_list)

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