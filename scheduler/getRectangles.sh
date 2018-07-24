#!/bin/bash

if [ "$1" = "" ]; then
	echo "usage: bash getRectangles.sh FILE"
	exit 0;
fi

cat $1 | grep "Packed" | cut -d' ' -f3,5,6 | tr '.,()=' ' ' | cut -d' ' -f1,7,8,16,17 | tr ' ' ','
