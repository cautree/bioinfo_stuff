library(dplyr)

df = data.frame( Yes = c(50,21),
                 No = c(131,2),
                 stringsAsFactors = F)

print(head(df))


df = readr::read_csv("mtcars.csv")
head(df)

#get the first row
df[1,]

##get the first column
df[,1]

## set the first column as index
df1 = df
rownames(df1) = df1$model
df1$model = NULL

## set the first column as index using dplyr

df1 = df %>%
   tibble::column_to_rownames( var = "model")
head(df1)

## filtering
df1 = df %>%
    dplyr::filter( mpg >25)
df1

## select var
df1 = df %>%
    dplyr::select( mpg, wt)
df1

##create a new var
df1 = df1 %>%
    dplyr::mutate( wt_round = round(wt, 0))
df1

summary(df1)

## get the column mean
as.data.frame(sapply(df[-1], mean, na.rm =T))


## get the unique values for a column
unique(df$am)

## tablulate a column 
table(df$am)

## keep only one row for am, which has the biggest weight
df_am = df %>%
  tidyr::nest(-am) %>%
  dplyr::mutate( data2 = purrr::map(.$data, function(x){
      x = x %>%
        dplyr::arrange( -wt)
      x = x[1,]
      return(x)

  })) %>%
  dplyr::select( am, data2) %>%
  tidyr::unnest()
df_am



### normalization using lambda function
names(df)
df2 = df
df2[-1] = apply( df2[-1],
                 2,
                 function(y) ( y - mean(y, na.rm = T))/ sd( y, na.rm = T))
head(df2)


## create a new column using two string column
df3 = df %>%
 dplyr::mutate( model_am = paste( model, am, sep="_"))
head(df3$model_am)


## group & counts
df %>%
    dplyr::group_by( am) %>%
    dplyr::summarize( n = n())

 ## group min
 df %>%
    dplyr::group_by( am) %>%
    dplyr::summarize( wt_min = min(wt, na.rm = T))


## group and count and min and max
df %>%
    dplyr::group_by( am) %>%
    dplyr::summarize(  n = n(),
                       wt_min = min(wt, na.rm = T),
                       wt_max = max(wt, na.rm = T))


 ## group and get the min, then get the value for another column
 ## keep only one row for am, which has the biggest weight
df %>%
  tidyr::nest(-am) %>%
  dplyr::mutate( data2 = purrr::map(.$data, function(x){
      x = x %>%
        dplyr::arrange( -wt)
      x = x[1,]
      return(x)

  })) %>%
  dplyr::select( am, data2) %>%
  tidyr::unnest() %>%
  dplyr::select( am, wt)


  df %>%
  dplyr::group_by( am, carb) %>%
  dplyr::summarize (n = n())


