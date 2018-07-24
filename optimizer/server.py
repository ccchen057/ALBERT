import multiprocessing
import socket
import time
import argparse

from loading import *
from global_searching import *

def handle(connection, address):
    import logging
    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger("process-%r" % (address,))
    try:
        logger.debug("Connected %r at %r", connection, address)
        while True:
            data = connection.recv(1024)
            if data == "":
                logger.debug("Socket closed remotely")
                break
            logger.debug("Received data %r", data)
            
            
            row = data.split(",")
            model_file = row[0]
            input_file = row[1]
            constraint_file = row[2]
            input_data = load_input(input_file)
            scalerX, clf, bound = load_model_and_conf(model_file)
            constraint = load_constraint(constraint_file)

            for key, value in constraint.items():
                set_bound(key, value[0], value[1], bound)

            from keras.models import load_model
            clf = load_model(model_file + '.h5')
            X, VMcount, VMtype = gen_conf(1048576, bound, input_data)

            minimum, conf = global_search(scalerX, clf, X, VMcount, VMtype)
            time = int(minimum)
            num_node = int(conf[2])

            msg = "Number of node: " + str(num_node) + '\n' + 'Tuned time: ' + str(time)

            connection.sendall(msg)
            logger.debug("Sent data")
    except:
        logger.exception("Problem handling request")
    finally:
        logger.debug("Closing socket")
        connection.close()

class Server(object):
    def __init__(self, hostname, port):
        import logging
        self.logger = logging.getLogger("server")
        self.hostname = hostname
        self.port = port

    def start(self):
        self.logger.debug("listening")
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind((self.hostname, self.port))
        self.socket.listen(1)

        while True:
            conn, address = self.socket.accept()
            self.logger.debug("Got connection")
            process = multiprocessing.Process(target=handle, args=(conn, address))
            process.daemon = True
            process.start()
            self.logger.debug("Started process %r", process)

if __name__ == "__main__":

    import logging
    logging.basicConfig(level=logging.DEBUG)
    server = Server("0.0.0.0", 9876)
    try:
        logging.info("Listening")
        server.start()
    except:
        logging.exception("Unexpected exception")
    finally:
        logging.info("Shutting down")
        for process in multiprocessing.active_children():
            logging.info("Shutting down process %r", process)
            process.terminate()
            process.join()
    logging.info("All done")
