chr = channel
  .of( 'chr1', 'chr2' )
  .map { it.replace("chr","") }  // same as  .map({ it.replace("chr","") })
                                 // same as .map { it.replaceAll("chr","") }
chr.view()


// below these three are the same, two ways to create tuple, 
// two ways to get the file name
fq_ch = channel
    .fromPath( 'reads/*.fastq.gz' )
    .map { file -> tuple(file.baseName, file.countFastq()) }

fq_ch = channel
    .fromPath( 'reads/*.fastq.gz' )
    .map { file -> [file.baseName, file.countFastq()] }

fq_ch = channel
    .fromPath( 'reads/*.fastq.gz' )
    .map { file -> tuple(file.getName(), file.countFastq()) }

//use filtering, now how in the filter first is file_name, second count
fq_ch = channel
    .fromPath( 'reads/*.fastq.gz' )
    .map { file -> tuple(file.baseName, file.countFastq()) }
    .filter { file_name, count -> count >1000}

// channel.of  and channel.fromList
// flatten turn list to many single item
list1 = [1,2,3]
ch = channel
  .of(list1)

ch = channel
  .fromList(list1)
  
ch.flatten()

// the oposite of flatten is collect
ch = channel
    .of( 1, 2, 3, 4 )

//collect turn the individuals into a list
// use map to change the order
ch.collect()
  .map{ it-> tuple( it[1], it[0], it[2] , it[3])}


//groupTuple()
ch = channel
     .of( ['wt','wt_1.fq'], ['wt','wt_2.fq'], ["mut",'mut_1.fq'], ['mut', 'mut_2.fq'] )
     .groupTuple()

//create a key using map
 channel.fromPath('data/*/*')
        .map{ it-> tuple(it.baseName.tokenize('.')[0], it)}
        .groupTuple()
        .view()

// this way works also, but notice how to split on ., has to use double \
 channel.fromPath('data/*/*')
        .map{ it-> tuple(it.getName().split("\\.")[0], it) }
        .groupTuple()
        .view() 
