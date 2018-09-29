#!/bin/bash

LANG=zh_TW.BIG5 ./$1

result=$?
echo $result

while [ $result > 0 ] 
do
	./test.sh
	result=$?
	echo $result
	sleep 3
done
