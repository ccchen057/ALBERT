import socket
import argparse

if __name__ == "__main__":
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("localhost", 9876))
    data = "some data"
    
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument("--m")
    parser.add_argument("--i")
    parser.add_argument("--c")
    args = parser.parse_args()
    model_file = args.m
    input_file = args.i
    constraint_file = args.c

    sock.sendall(model_file + ','+ input_file + ',' + constraint_file)
    result = sock.recv(1024)
    print result
    sock.close()
