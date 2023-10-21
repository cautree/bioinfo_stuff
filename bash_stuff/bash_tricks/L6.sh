
# this does not work on mac
#cat data.tsv | head -1 | tr "\t" "" | cat -n
cat data.tsv | head -1 | tr -d "\t"  | cat -n


# head -1 : print the first line tr translate tab to newline cat -n print the line number.  You can use nl too


cat data.tsv | nl



# cat data.tsv | head -1 | tr "\t" "" | nl
cat data.tsv | head -1 | tr -d "\t"  | nl



#use sed, you can change to any line number

# cat data.tsv | sed -n '1s/\t//gp'


#use csvkit

## has to install csvcut
## csvcut -nt -l data.tsv
