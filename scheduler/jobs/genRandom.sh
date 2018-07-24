#/bin/bash


begin=$1
end=$2
space=1
random=$(od -vAn -N4 -tu4  /dev/urandom)
result=$(echo "$random%(($end-$begin)/$space+1)*$space+$begin" | bc)

echo $result
