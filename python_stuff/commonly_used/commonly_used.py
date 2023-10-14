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

df1 = pd.DataFrame( range(1,1001), columns = ['insert_size'])
df1.head()

path = 'Ecoli_20bb_F03.insert.csv'
samp = path.replace('.insert.csv', '')
df2 = pd.read_csv(path, usecols = [0,1], comment='#')
df2.columns = ['insert_size', samp]
df2.head()

df = df1.merge( df2, how = 'left').fillna(0)
df.head()

#zip dict
endings = ['.align.txt', '.insert.txt']
sheetnames = [ 'CollectAlignmentSummary', 'CollectInsertSizeMetrics']
sheet_dict = dict(zip(endings, sheetnames))

#delimiter is an alias of sep
df = pd.read_csv('230330-UDI-4_C11.align.txt', delimiter= '\t', skiprows =6, nrows =1)
df.head()
df = df.T
df.head()

path = '230330-UDI-4_C11.align.txt'
ending = '.align.txt'
sample = path.replace(ending, '').split('/')[-1]
sample
df.columns = [sample]
df.head()


tmp = pd.DataFrame([])
tmp.head()
df = df.merge( tmp, left_index = True, right_index =True, how ='outer')
df.head()


output_path = "metrics.xlsx"
df1.T.sort_index()
df1.T.sort_index().to_excel(output_path)





