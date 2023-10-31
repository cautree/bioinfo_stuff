#!/usr/local/bin/nextflow

c1 = Channel.of( 1, 2, 3 )
c2 = Channel.of( 'a', 'b' )
c3 = Channel.of( 'z' )

//spit out queue channel NOT in order 
c1.mix(c2,c3)
   .view()
  
//spit out queue channel in order  
c1.concat(c2,c3)
  .view()