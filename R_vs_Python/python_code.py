import pandas as pd
import numpy as np

df = pd.DataFrame( { "Yes": [50,21],
                     "No": [131,2], 
                     })
print(df.head())


s1 = pd.Series([1,2,3,4,5])
s2 = pd.Series([2,3,4,5,6])
df = pd.concat([s1,s2],axis=1)
print(df.head())


df = pd.read_csv("mtcars.csv")
print(df.head())

##get the first row
print(df.iloc[0])
print(df.iloc[0, :])

## get the first column
print(df.iloc[:,0])

print(df.shape)

## set the index
df.set_index("model", inplace=True)
print(df.head())
print(df.index)


## filter by column value
print(df.loc[df.mpg >25])

## select columns
df1 = df[ ["mpg","wt"]]
print(df1.head())

## create a new variable
df1[ "mpg_round"] = round(df1.mpg, 0)
print(df1.head())

## get the summary 
df.describe()


## column mean
print(pd.DataFrame (df.mean()) )


## get the unique value for a column
print(df.am.unique())

## tabulate a column
print(df.am.value_counts())


## select rows which has the biggest weight in each am category
weight_idx = df.groupby("am")["wt"].aggregate( "idxmax")
print(weight_idx)
df_am = df.loc[ weight_idx]
print(df_am.head())

## one line to do the thing above
df_am_2 = df.reset_index(names=['model']).groupby(['am']).apply(lambda df: df.loc[df.wt.idxmax()])
print(df_am_2.head())


## agregate for more function
print(df.groupby(['am']).wt.agg([ len, min, max]))


## normallization using lambda function
## https://stackoverflow.com/questions/20708455/different-results-for-standard-deviation-using-numpy-and-r

# notice you have to use ddof = 1 in the np.std function to get the same value as in R
print(df.columns)
df2 =df.apply( lambda x : (x-np.mean(x))/np.std(x,  ddof = 1))
print(df2.head())


## create a new column by concat string
df3 = df
df3['am'] = df3.am.astype("str")
df3['model_am'] = df3.index + '_' + df3.am
print(df3.model_am)


## group and counts
print(df.groupby('am').am.value_counts())

## group, get the min for another variable
print(df.groupby('am').wt.min())



## multi index, and count the n in each category
df_multi = df.groupby(['am','carb'] ).vs.agg([len])
print(df_multi)

mi = df_multi.index
print(type(mi))
print(df_multi.reset_index())

print(df_multi.reset_index().sort_values(by='len'))


print(df_multi.reset_index().sort_values(by='len', ascending=False))

## sort by multiple values
df.sort_values(by=['am', 'vs'])
print(df.head())

## data types
print(df.dtypes)

print(df.am.dtype)

## change datatypes
df['am'] = df.am.astype('int64')
print(df.am.dtype)


## missing values
df5 = df
df5['am'][4:8] = np.NaN
df_null = pd.isnull(df5).sum()
print(df_null)

## fill the missing value
df5 = df5.fillna(-9)
df_null = pd.isnull(df5).sum()
print(df_null)

## change char in a specific column
print(df5.index)
df5.index = df5.index.str.replace("RX4", "RX5")
print(df5.index)


## rename a column, has to use columns=, and in the dict, the old name is the key
df5 = df5.rename(columns= { "gear": "GEAR"})
print(df5.columns)

## rename index
print(df5.index)
df5 = df5.rename_axis("MODEL", axis='rows')
print(df5.head())

## concatenate, similar to dplyr::bind_rows()
dfa = pd.read_csv("mtcars3.csv")
dfb = pd.read_csv("mtcars4.csv")
print(np.sum(dfa.columns == dfb.columns) == dfa.shape[1]) ##true
dfab = pd.concat([dfa, dfb])
print(dfab.shape[0] == (dfa.shape[0] + dfb.shape[0]) ) ## true





