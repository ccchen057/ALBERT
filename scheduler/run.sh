#!/bin/bash

python optimizer/server.py &
SERVER_PID=$(echo $!)

sleep 2

./scheduler 200 0.1 4 12 ~/albert-script-0426/scheduler/gen_case/job_8app.0_00.txt 1

kill -15 $SERVER_PID
