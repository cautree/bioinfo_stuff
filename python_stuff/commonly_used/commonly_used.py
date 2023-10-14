## return a list of files in the directory
import os 
os.listdir(".")

import pandas as pd
excel = pd.ExcelFile("20231003_MiSeq_hg38.xlsx")
## this will return all the sheet in a list
excel.sheet_names
## if the sheet1 is name sheet1, this will return sheet1 as a dataframe
excel.parse("sheet1")


##list comprehension to get the files meet some conditions in a folder
paths =[ path for path in os.listdir(".") if path.endswith('.insert.txt')]


## create a dataframe from scratch
df = pd.DataFrame( range(1,1001), columns = ['insert_size'])

## read in data for only specific columns, and asign column names
path='Ecoli_20bb_A03.insert.csv'
samp = path.replace('.insert.csv', '')
df = pd.read_csv(path, usecols=[0,1], comment="#")
df.columns = ["insert_size", samp]
df.head()

