#!/opt/anaconda3/bin/python

import pandas as pd
import os

##put the name.txt and rename.py in the fastq file folder

path = 'name.txt'
# sep is the alias for delimiter
target_names = pd.read_csv(path, sep= "\t")
name_dict = dict(zip( target_names.old_id, target_names.new_id))

paths = [ path for path in sorted(os.listdir('.'))]

for path in paths:
    old_id = path
    try:
        out = path.replace(old_id, name_dict[old_id])
        print(path, out)
        os.rename(path, out)
    except:
        pass

