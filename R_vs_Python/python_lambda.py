import pandas as pd

s = pd.Series([1, 2, 3, 4]) 
print(s.loc[lambda x: x > 1])
print(s[lambda x: x > 1])



df = pd.DataFrame({'A': [1, 2, 3], 
                 'B': [10, 20, 30]})
df_s = df[lambda x: (x['A'] != 1) & (x['B'] != 30)]
print(df_s)