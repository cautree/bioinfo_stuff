
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


#get all the folders' sizes in the current folder
du -h --max-depth=1

#the total size of the current directory
du -sh .


#disk usage
df -h

# make directory using the current date
# full date; same as %Y-%m-%d
# https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
$ mkdir $(date +%F)


#copy large files with rsync
#copy the from_dir directory to the to_dir directory
rsync -av from_dir to_dir

#copy every file inside the frm_dir to to_dir. Note the trailing slash
rsync -av from_dir/ to_dir

#re-copy the files avoiding completed ones
rsync -avhP from_dir to_dir
#-a, --archive               archive mode; 
#-v, --verbose               increase verbosity
# -n, --dry-run               show what would have been transferred
# -h, --human-readable        output numbers in a human-readable format
#  -P                          same as --partial --progress

#exit a dead ssh session

#press (tilde then period):

~.


#sort VCF with header: did not get this one
cat my.vcf | awk '$0~"^#" { print $0; next } { print $0 | "sort -k1,1V -k2,2n" }'


#split a bed file by chromosome

cat regions.bed | sort -k1,1 -k2,2n | sed 's/^chr//' | awk '{close(f);f=$1}{print > f".bed"}'

#or
awk '{print $0 >> $1".bed"}' regions.bed

#sed to remove the chr and awk split the files to 1.bed, 2.bed etc.
#split large file by id/label/column. you can change $1 to $2 etc depending on which column you want to use
awk '{print >> $2; close($2)}' 20230621_MiSeq-Sharkboy_1654.tsv


cat example.bed
#chr1 12 14 sample1
#chr1 10 15 sample2
#chr2 10 20 sample1
#chr2 22 33 sample2

awk '{print >> $1".bed"; close($1".bed")}' example.bed
#it gives you chr1.bed, chr2.bed

awk '{print >> $4".bed"; close($4".bed")}' example.bed
#it gives you sample1.bed, sample2.bed


#print out unique rows based on the first and second column

awk '!a[$1,$2]++' example2.bed

#In R:
#df %>% dplyr::distinct(column1, column2, .keep_all =TRUE)

#Bonus: sort based on unique (first and second)column
sort -u -k1,2 example2.bed



cat -A data.tsv
#ID^Ihead1^Ihead2^Ihead3^Ihead4$
#1^I25.5^I1364.0^I22.5^I13.2$
#2^I10.1^I215.56^I1.15^I22.2$
#^I means tab, $ means the end of the line. This is useful when you get a file and see if you do see a tab between columns or you may have 2 tabs between the columns. Note on mac you will need to use gnu utilities and use gcat -A. (install the GNU utility)

sed -n l data.tsv
#ID\thead1\thead2\thead3\thead4$
#1\t25.5\t1364.0\t22.5\t13.2$
#2\t10.1\t215.56\t1.15\t22.2$
#now, tab is denoted as \t and $ means the end of the line.

## remove different prefix
files=( "a.txt"  "b.csv")
for file in ${files[@]}; do
echo ${file%.*}
done