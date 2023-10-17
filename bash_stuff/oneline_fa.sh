#!/bin/bash

while read line; do 
echo $line

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < ION/${line} > ION_oneline/${line}


done < fafile
