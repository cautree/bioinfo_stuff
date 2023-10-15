// process_with_python.nf
nextflow.enable.dsl=2

process PYTHON_SCRIPT {

  debug true // enable debug mode which prints the stdout
  
  input:
  path dataset

  script:
  """
  #!/usr/bin/env python
  import os
  import pandas as pd
  df = pd.read_csv("${dataset}")
  print(df.head())
  
  """

}


workflow {
  data = Channel.fromPath("mtcars.csv")
  PYTHON_SCRIPT(data)
}