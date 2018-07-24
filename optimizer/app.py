from flask import Flask, render_template,request

import numpy as np
import keras.models
import re

import sys
import os

app = Flask(__name__)
global model, graph

from loading import *
from global_searching import *

import argparse
parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument("--m")
args = parser.parse_args()
model_dir = args.m

models = [  "wordcount", 
            "terasort", 
            "pagerank_1", 
            "pagerank_2", 
            "kmeans_1", 
            "kmeans_2", 
            "trianglecount_1", 
            "trianglecount_2"
        ]

model_dict = {}
cnt = 0
for i in models:
    model_dict[i] = cnt
    cnt += 1

scalerX = []
model = []
graph = []
bound = []
for i in models:
    
    tmp1, tmp2, tmp3, tmp4 = load_model_and_conf(model_dir + i)
   
    scalerX.append(tmp1)
    model.append(tmp2)
    graph.append(tmp3)
    bound.append(tmp4)

@app.route('/', methods=['GET','POST'])
def optimize():

    input = request.get_data()
    print input
    
    row = input.split(",")
    model_id = model_dict[row[0]]
    input_file = row[1]
    constraint_file = row[2]
    input_data = load_input(input_file)
    constraint = load_constraint(constraint_file)
    deadline = float(row[3])

    b = bound[model_id].copy()
    for key, value in constraint.items():
        set_bound(key, value[0], value[1], b)

    X, VMcount, VMtype = gen_conf(1048576, b, input_data)
    #X, VMcount, VMtype = gen_conf(128, b, input_data)

    minimum, conf = global_search(scalerX[model_id], model[model_id], graph[model_id], X, VMcount, VMtype, deadline)

    time = int(minimum)
    num_node = int(round(conf[2]))

    msg = "Number of node: " + str(num_node) + '\n' + 'Tuned time: ' + str(time)
    return msg

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 9000))
    app.run(host='0.0.0.0', port=port)
