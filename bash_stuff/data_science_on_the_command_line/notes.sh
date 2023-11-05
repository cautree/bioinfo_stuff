 ## show fac.py with syntax highlight
 bat fac.py

## find the type of command
 type -a cd

##The -n option, which stands for newline, specifies that echo should not output a trailing newline.
echo -n "Hello" > greeting.txt
echo " World" >> greeting.txt

## get the counts on more than one file
wc -w greeting.txt movies.txt

## avoid error report, 404.txt does not exit
cat movies.txt 404.txt 2> /dev/null

## past 5 days
dseq 5 > dates.txt
## add the line count
< dates.txt nl > dates_nl.txt

## do the same thing as above
< dates.txt nl | sponge dates.txt

## -v verbose
mkdir -v backup

## csvlook
csvlook /data/ch07/tips.csv 

## bat -A file.txt to see the spaces, tabs, etc
bat -A /data/data/ch04/stream.py

## save and then look at the first 5
seq 0 2 100 | tee even.txt | trim 5

## tldr similar to man, but simple version
tldr tar | trim 20

##extract files from an archive, use gzip as the decompression algorithm and use file logs.tar.gz.
tar -xzf logs.tar.gz

##tar -tzf logs.tar.gz | trim
tar -tzf logs.tar.gz | trim

## extract and put into new folder
mkdir logs 
tar -xzf logs.tar.gz -C logs

## unpack looks at the extension of the file that you want to decompress, and calls the appropriate command-line tool
unpack logs.tar.gz

## -H specify has no header
csvlook -H tmnt-missing-newline.csv

##the tools in2csv, csvgrep, and csvlook are part of CSVkit, which is a collection of command-line tools to work with CSV data.
csvgrep top2000.csv --columns ARTIEST --regex '^Queen$' | csvlook -I


## -- names check the sheetname
in2csv --names top2000.xlsx

## most frequently used 10 words
curl -sL "https://www.gutenberg.org/files/11/11-0.txt" | \
tr '[:upper:]' '[:lower:]' | \
grep -oE "[a-z\']{2,}" | \
sort | \
uniq -c | \
sort -nr | \
head -n 10

##
curl -sL "https://raw.githubusercontent.com/stopwords-iso/stopwords-en/master/
stopwords-en.txt" | sort | tee stopwords | trim 20


##Obtain the patterns from a file (stopwords in our case), one per line, with -f. 
#Interpret those patterns as fixed strings with -F. 
##Select only those lines containing matches that form whole words with -w. Select non-matching lines with -v
curl -sL "https://www.gutenberg.org/files/11/11-0.txt" | \
tr '[:upper:]' '[:lower:]' | \
grep -oE "[a-z\']{2,}" | \
sort | \
grep -Fvwf stopwords | \
uniq -c | \
sort -nr | \
head -n 10

## remove the second line
sed -i '2d' top-words-4.sh

##
grep -E "fizz|buzz" fb.seq | sort | uniq -c | sort -nr > fb.cnt 

## add column head
< fb.cnt awk 'BEGIN { print "value,count" } { print $2","$1 }' > fb.csv

## output line 1 line 2, etc
seq -f "Line %g" 10 | tee lines

## first 3 lines
< lines head -n 3
< lines sed -n '1,3p'
< lines awk 'NR <= 3'

## removing the first 3 lines (not 4)
< lines tail -n +4
< lines sed '1,3d'
< lines sed -n '1,3!p'

## remove the last 3
< lines head -n -3

## line 4 to 6
< lines sed -n '4,6p'
< lines awk '(NR>=4) && (NR<=6)'
< lines head -n 6 | tail -n 3

## print odd lines
< lines sed -n '1~2p'
< lines awk 'NR%2'

## print even lines
< lines sed -n '0~2p'
< lines awk '(NR+1)%2'

## -E for regular expression
< alice.txt grep -E '^CHAPTER (.*)\. The'

## none empty lines
< alice.txt grep -Ev '^\s$' | wc -l

## sample by 1&
seq -f "Line %g" 1000 | sample -r 1%

##add a 1 second delay between each line being printed and to only run for 5 seconds,
##ts73 adds a timestamp in front of each line
seq -f "Line %g" 1000 | sample -r 1% -d 1000 -s 5 | ts

## get the word at least length of 2
< alice.txt grep -oE '\w{2,}' | trim

# start with a end with e
< alice.txt tr '[:upper:]' '[:lower:]' | 
grep -oE '\w{2,}' |
grep -E '^a.*e$' |
sort | uniq | sort -nr | trim


## replace and deleting values
echo 'hello world!' | tr ' ' '_'

##If more than one character needs to be replaced, then you can combine that:
echo 'hello world!' | tr ' !' '_?'

## rm
echo 'hello world!' | tr -d ' !'

##-c option indicates that complement of that should be used. In other words, this command only keeps lowercase letters.
echo 'hello world!' | tr -d -c '[a-z]'


## case change
echo 'hello world!' | tr '[a-z]' '[A-Z]'
echo 'hello world!' | tr '[:lower:]' '[:upper:]'


##
echo ' hello     world!' |
> sed -re 's/hello/bye/' | 
> sed -re 's/\s+/ /g' | 
> sed -re 's/\s+//'

## same thing one line
echo ' hello     world!' | sed -re 's/hello/bye/;s/\s+/ /g;s/\s+//'
