import csv
import sys
from sklearn import preprocessing
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_regression
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestRegressor

def read_file(input_file, X, y,  Ytarget):
	f = open(input_file, 'rb')

	for row in csv.reader(f):
        	row = [float(i) if i else 0 for i in row]
        	Y = row[0]
		#if Y > 0.0:
               	row2 = row[1:]
                X.append(row2)
                y.append(float(Y))
                Ytarget.append(float(Y))
	f.close()
	
def scale_values(X, y):
	
	scalerX = preprocessing.MinMaxScaler([0,1.0])
	X = scalerX.fit_transform(X)
	#y = scalerY.fit_transform(y)
	
	return X, y, scalerX

def feature_select(X, y, k):
	selecter= SelectKBest(f_regression, k=k) #reduce to k features
	X = selecter.fit_transform(X, y)
	scores = selecter.scores_
	print "feature scores : ",scores
	return X

def pca(X,n):
	pca = PCA(n_components=n)
	print pca.fit(X)
	X = pca.transform(X)
	return X

def randomforest(X, y):
	print("Random forest feature importance")
	rf = RandomForestRegressor()
	rf.fit(X, y)
	print "Features sorted by their score:"
	print map(lambda x: round(x, 4), rf.feature_importances_)
