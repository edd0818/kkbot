#!/bin/bash

echo $1.exp
str=$1
path=${str%/*}
echo "$path"

iconv -f utf-8 -t big5 $1 > $1.exp
iconv -f utf-8 -t big5 $path/lib.sh > $path/lib.exp
chmod +x $1.exp
chmod +x $path/lib.exp

LANG=zh_TW.BIG5 expect -f $1.exp $path/lib.exp
result=$?
echo $result
echo "Start to retry."
while [ $result > 0 ] 
do
	LANG=zh_TW.BIG5 expect -f $1.exp $path/lib.exp
	result=$?
	echo "Retry again"
	sleep 3
done
