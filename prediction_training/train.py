from sklearn.neural_network import MLPRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn.svm import SVR
from keras.models import Sequential
from keras.layers import Dense, Activation, Dropout
from keras.layers.recurrent import LSTM
from keras.layers import Embedding
from keras.optimizers import SGD
from keras.optimizers import Adam
from keras.optimizers import Adagrad
from keras import losses
from keras.initializers import TruncatedNormal
from keras import regularizers
from keras.layers.normalization import BatchNormalization
from keras.layers.advanced_activations import LeakyReLU
from keras.callbacks import *

def NN_train(X, y, args):
        print "Training start..."
        clf = MLPRegressor(solver=args.SOLVER,hidden_layer_sizes=([args.NUM_NEURAL]*args.NUM_LAYER),max_iter=args.MAX_ITER,learning_rate_init=args.L_R_INIT, batch_size=args.BATCH_SIZE, power_t=args.POWER_T, alpha=args.ALPHA)
        print clf.fit(X, y)
        score = clf.score(X, y)
        print score
        print "Training finished..."
        return clf, score
def DT_train(X,y,args):
        clf = DecisionTreeRegressor(max_depth = 100)
        print clf.fit(X, y)
        score = clf.score(X, y)
        print score
        return clf, score
	
def SVR_train(X,y,args):
        clf = SVR(kernel='rbf',C=1,gamma=0.01,epsilon=0.0001)
        print clf.fit(X, y)
        score = clf.score(X, y)
        print score
        return clf, score

def Keras_train(X,y,T,t):
        
	model = Sequential()
	num_n = len(X[0])
	input_dim = len(X[0])

	act_func = 'selu'

	filepath="weights.best.hdf5"
	checkpoint = ModelCheckpoint(filepath, monitor='val_loss', verbose=0, save_best_only=True, mode='auto')
	model.add(Dense(input_dim, activation=act_func,
                                        input_dim=input_dim,
                                        kernel_initializer=TruncatedNormal(mean=0.0,stddev=0.05, seed=None),
                                        kernel_regularizer=regularizers.l2(0.01)
                                        )) # input layer
	
	#for i in range(3):
	#	model.add(Dense(num_n, activation=act_func))
	
	model.add(Dense(100, activation=act_func))
	model.add(Dense(100, activation=act_func))
	model.add(Dense(100, activation=act_func))
	model.add(Dense(100, activation=act_func))
	
	model.add(Dense(1)) # output layer

	adam = Adam()
	earlyStopping = EarlyStopping(monitor='val_loss', patience=500, verbose=0, mode='auto')
	
        
        #model.compile(optimizer=adam, loss='mean_absolute_percentage_error')
        model.compile(optimizer=adam, loss='mean_absolute_error')

	model.summary()
        history = model.fit(X, y, epochs=10000, batch_size=16, validation_data=(T, t), callbacks=[earlyStopping, checkpoint])
        #history = model.fit(X, y, epochs=10000, batch_size=16, validation_data=(T, t))

	score = model.evaluate(T, t, batch_size=100)
        # load weights
        model.load_weights("weights.best.hdf5")

	print
        print "Score: ",
        print score

        return model, score

