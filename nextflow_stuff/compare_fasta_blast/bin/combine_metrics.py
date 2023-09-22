#!/usr/bin/env python3
import glob
import sys
import pandas as pd
import os


out_name = sys.argv[1]

files=glob.glob('*.csv')

col_names = ['pair_id', 'sample1', 'sample2', 'sample1_length', 'sample2_length', 'Score', 'Expect', 'Identities', 'Gaps', 'Strand']
info=pd.DataFrame(columns= col_names)

for f in sorted(files):

    filename=f.split('.')[0]

    try:
        df1=pd.read_csv(f, names=col_names)

       
    except:
        columns = col_names

        data = [filename] + ['']*9
        df1 = pd.DataFrame([data], columns = columns)

    info= pd.concat([info, df1], ignore_index=True)
    
info = info[info["pair_id"].str.strip() != 'pair_id']    
info.to_csv(out_name + '.csv', index=False)


