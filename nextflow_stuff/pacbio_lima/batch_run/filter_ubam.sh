#!/bin/bash

ls -1 ubam > file

while read line ; do 

a=$(echo $line | cut -d_ -f2)
b=$(echo $line | cut -d_ -f4)

if [ $a == $b ]
then
    echo $line
fi
done < file