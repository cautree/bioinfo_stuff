//process_repeat.nf
nextflow.enable.dsl=2

process COMBINE {
  input:
  val x
  each y

  script:
  """
  echo $x and $y
  """
}

ch_num = Channel.of(1, 2)
ch_letters = Channel.of('a', 'b', 'c', 'd')

workflow {
  COMBINE(ch_num, ch_letters)
}

//either have each on x or y, the output is 8 combinations
//if none of them have each defined, the output is only 2 combinations