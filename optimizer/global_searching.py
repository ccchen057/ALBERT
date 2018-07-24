import numpy as np

def set_bound(key, l_value, u_value, bound):

    if isinstance(l_value, int):
        bound[key] = [int(l_value), int(u_value)]
    else:
        bound[key] = [float(l_value), float(u_value)]

    return bound

def gen_conf(N, bound, input_data):

    X = []
    for key, value in bound.items():

        if value[0] == value[1]:
            tmp = np.empty(N)
            tmp[:] = value[0]
            X.append(tmp)
        else:
            if isinstance(value[0], int):
                tmp = np.random.randint(value[0], value[1]+1, size = N)
                X.append(tmp)
            else:
                tmp = np.random.uniform(value[0], value[1], N)
                X.append(tmp)

    VMcount = X[2].copy()
    VMtype = X[3].copy()
    
    X = np.array(X)
    X = np.transpose(X)
    
    input_data = np.array(input_data)
    input_data = np.repeat(input_data, N, axis = 0)

    X = np.c_[X, input_data]

    return X, VMcount, VMtype

def global_search(scalerX, model, graph, X, VMcount, VMtype, deadline):
  
    #for i in X:
    #    print i

    X = scalerX.transform(X)

    with graph.as_default():
        Y = model.predict(X, verbose=1, batch_size = 1048576)
    Y[Y < 0] = np.inf
    Y[Y > deadline] = np.inf

    #for i in Y:
    #    print i

    Y_cost = np.multiply(Y.flatten(), VMcount)
    Y_cost = np.multiply(Y_cost, VMtype)

    minimum = np.amin(Y_cost)
    minimum_index = np.argmin(Y_cost)
    
    time = Y[minimum_index]
    conf = scalerX.inverse_transform([X[minimum_index]])

    if time == np.inf:
        time = deadline + 1

    return time, conf[0]
