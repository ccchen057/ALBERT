from sklearn.externals import joblib
from collections import OrderedDict
import csv
from keras.models import model_from_json
import keras.models
import tensorflow as tf

def load_model_and_conf(model_file):
    #from keras.models import load_model

    scalerX = joblib.load(model_file + '.scl.pkl')
    #clf = load_model(model_file + '.h5')

    json_file = open(model_file + '.json','r')
    loaded_model_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_model_json)
    loaded_model.load_weights(model_file + '.h5')
    loaded_model.compile(loss='mean_absolute_percentage_error', optimizer='adam', metrics=['accuracy'])
    graph = tf.get_default_graph()

    f = open('bound.default.csv','rb');
    #f = open('bound.default_no_op.csv','rb');

    bound = OrderedDict()
    for row in csv.reader(f):

        key = row[0]
        if row[4] == 'int':
            value = [int(row[1]), int(row[2])]
        else:
            value = [float(row[1]), float(row[2])]

        bound[key] = value

    f.close()

    return scalerX, loaded_model, graph, bound

def load_input(input_file):

    input_data = []
    
    f = open(input_file,'rb');
    for row in csv.reader(f):
        row = [float(i) if i else 0 for i in row]
        input_data.append(row)
    f.close()
    
    return input_data
def load_constraint(constraint_file):

    f = open(constraint_file,'rb');

    constraint = OrderedDict()
    for row in csv.reader(f):

        key = row[0]
        if row[4] == 'int':
            value = [int(row[1]), int(row[2])]
        else:
            value = [float(row[1]), float(row[2])]

        constraint[key] = value

    f.close()

    return constraint
