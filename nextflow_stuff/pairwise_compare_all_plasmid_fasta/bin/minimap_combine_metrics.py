#!/usr/bin/env python3
import glob
import sys
import pandas as pd
import os


out_name = sys.argv[1]

files=glob.glob('*.txt')

col_names = ["query_name", "query_length", "query_start", "query_end", "strand",
"target_name", "target_length", "target_start", "target_end",
"residue_matches", "alignment_block_length", "mapping_quality"]
info=pd.DataFrame(columns= col_names)

for f in sorted(files):

    filename=f.split('.')[0]

    try:
        df1=pd.read_csv(f, names=col_names)

       
    except:
        columns = col_names

        data = [filename] + ['']*11
        df1 = pd.DataFrame([data], columns = columns)

    info= pd.concat([info, df1], ignore_index=True)
    
#info = info[info["query_name"].str.strip() != 'pair_id']    
info.to_csv(out_name + '.csv', index=False)


