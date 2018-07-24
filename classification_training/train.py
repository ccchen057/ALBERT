
from sklearn.neural_network import MLPClassifier
from sklearn.tree import DecisionTreeRegressor
from sklearn.svm import SVR

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_moons, make_circles, make_classification
from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.gaussian_process import GaussianProcessClassifier
from sklearn.gaussian_process.kernels import RBF
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis

def NN_train(X, y, args):
	print "Training start..."
	clf = MLPClassifier(solver=args.SOLVER,hidden_layer_sizes=([args.NUM_NEURAL]*args.NUM_LAYER),max_iter=args.MAX_ITER,learning_rate_init=args.L_R_INIT, batch_size=args.BATCH_SIZE, power_t=args.POWER_T, alpha=args.ALPHA)
	print clf.fit(X, y)
	score = clf.score(X, y)
	print score
	print "Training finished..." 
	return clf, score


def ALL_train(X, y, args):
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
	classifiers = [
		KNeighborsClassifier(3),
		SVC(kernel="linear", C=0.025),
		SVC(gamma=2, C=1, decision_function_shape='ovo'),
		#GaussianProcessClassifier(1.0 * RBF(1.0), warm_start=True),
		DecisionTreeClassifier(max_depth=20),
		RandomForestClassifier(max_depth=20, n_estimators=10, max_features=1),
		AdaBoostClassifier(),
		GaussianNB(),
		MLPClassifier(solver=args.SOLVER,hidden_layer_sizes=([args.NUM_NEURAL]*args.NUM_LAYER),max_iter=args.MAX_ITER,learning_rate_init=args.L_R_INIT, batch_size=args.BATCH_SIZE, power_t=args.POWER_T, alpha=args.ALPHA),
		#QuadraticDiscriminantAnalysis()
	]

	X = np.array(X)
	y = np.array(y)
	clfs = []
	scores = []
	for name, clf in zip(names, classifiers):
		print clf.fit(X, y)
		score = clf.score(X, y)
		print name, score
		clfs.append(clf)
		scores.append(score)
		
	print "Training finished..."
	return clfs, scores
