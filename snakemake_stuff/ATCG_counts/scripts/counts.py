###############
### IMPORTS ### 
###############
import os 
import sys
import pandas as pd
#import snakemake
from typing import TextIO


#############
### SETUP ###
#############
# Using OOP, we can directly reference attributes from the current
# Snakemake rule. 


seq_file: str = snakemake.input.r2
out_file: str = snakemake.output.r2_counts

##############################
### FIND FULL MATCH CIGARS ###
##############################

fq = pd.read_csv(seq_file, names = ['seq'])

data = [[n+1] + fq.seq.str[n].value_counts()[['A', 'C', 'G', 'T']].tolist() for n in range(25)]

pd.DataFrame(data, columns = ['position', 'A', 'C', 'G', 'T']).to_csv(out_file, index = False)


