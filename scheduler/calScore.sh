#!/bin/bash

if [ "$1" = "" ]; then
    echo "usage: bash calScore.sh FILE"
    exit 0;
fi
FILE=$1

app=$(cat $FILE | grep finalNode -B4 | grep cmd | cut -d' ' -f5)
time=$(cat $FILE | grep finalNode -B4 | grep JobInfo | cut -d'(' -f4 | cut -d')' -f1)
x=$(cat $FILE | grep finalNode -A3 | grep Pack | cut -d'(' -f3 | cut -d',' -f1)
w=$(cat $FILE | grep finalNode -A3 | grep Pack | cut -d'(' -f5 | cut -d',' -f1)

app=($app)
time=($tume)
x=($x)
w=($w)

count=${#w[@]}

L_score=0
L_cnt=0
S_score=0
S_cnt=0

for i in `seq 1 $count`; do

	if [ ${app[$i-1]} == '4' ]; then
		L_score=$((w[$i-1]+L_score))
		L_cnt=$((L_cnt+1))
	else
		S_score=$((w[$i-1]+x[$i-1]+S_score))
		S_cnt=$((S_cnt+1))
	fi
done

#echo $L_score
#echo $L_cnt
#echo $S_score
#echo $S_cnt

echo "L_score: $((L_score/L_cnt))"
echo "S_score: $((S_score/S_cnt))"
