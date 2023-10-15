// process_with_R.nf
nextflow.enable.dsl=2

process R_SCRIPT {

  debug true // enable debug mode which prints the stdout
  
  publishDir path: 'output', mode: 'copy', overwrite: true
  
  input:
  path dataset
  
  output:
  path "*.csv"


  script:
  """
  #!/usr/bin/env Rscript
  
  library(dplyr)
  library(readr)
  library(ggplot2)
  print("$dataset")
  df = readr::read_csv("${dataset}")
  print(head(df))
  
  df_s = df[1:5,]
  readr::write_csv( df_s, "small_mtcars.csv")
  
  
  """

}


workflow {
  data = Channel.fromPath("mtcars.csv")
  R_SCRIPT(data)
}
