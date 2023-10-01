library(dplyr)
library(rlang)


### part 1, preparation
remove_NA = function(x){
  x = x[ ! is.na(x)]
  return(x)
}

get_con_cat_var = function(df  ){
  
  ID_var =  grep( "ID|id|Id", names(df), value = T )
  non_ID_var = setdiff( names(df), ID_var)
  df_non_ID = df[ names(df) %in% non_ID_var]
  
  
  df_length = as.data.frame( sapply( sapply( sapply( df_non_ID, unique), remove_NA), length))
  names(df_length) = "unique_vals"
  
  df_length = df_length %>% 
    tibble::rownames_to_column( var = "variable")
  
  
  for (i in df_length$unique_vals) {
    
    if  (i %in% c(3:6) ) {
      stop("please converting some variables into the right category variables")
    }
    
  }
  
  
  cat_var = df_length %>% 
    dplyr::filter( unique_vals == 2) %>% 
    dplyr::pull( variable)
  
  
  ## suppose the unique_vals need to be at last 7 to be continous
  con_var = df_length %>% 
    dplyr::filter( unique_vals >= 7) %>% 
    dplyr::pull( variable)
  
  return( list(cat_var, con_var))
  
}



## part2 create_cat_table

summary_for_cat = function(data, col){
  
  col = enquo(col)
  data %>%
    dplyr::summarise(mean = round(mean(!!col, na.rm = TRUE)*100,0),
                     n= sum( !!col , na.rm=TRUE),
                     clin = stringr::str_replace_all( expr_text(col), "~","") ) %>% 
    dplyr::mutate(res = paste(n, " (", mean,"%", ")", sep="")) %>% 
    dplyr::select(-mean, -n)
  
}

create_cat_table = function( df, trt_var, cat_var ){
  
  trt = sym(trt_var)
  df_non_case = df %>%
    dplyr::filter( !!trt ==0)
  
  df_case = df %>%
    dplyr::filter( !!trt ==1)
  
  df_total = df
  
  col = cat_var
  col = syms(col)
  
  summary_non_case_cat = purrr::map_dfr( col, summary_for_cat, data=df_non_case)
  summary_case_cat = purrr::map_dfr( col, summary_for_cat, data=df_case)
  summary_total_cat = purrr::map_dfr( col, summary_for_cat, data=df_total)
  
  cat_table = summary_non_case_cat %>%
    dplyr::left_join( summary_case_cat, by = "clin") %>% 
    dplyr::left_join(summary_total_cat, by ="clin")
  
  names(cat_table) = c("clin","non_cases","cases","Total")
  
  return(cat_table)
  
}



## part 3 create con table
summary_for_con = function(data, col){
  
  col = enquo(col)
  data %>%
    dplyr::summarise(median = round(median(!!col, na.rm = TRUE),0),
                     first_quantile = round(quantile(!!col, 0.25,na.rm = TRUE),0),
                     third_quantile = round(quantile(!!col, 0.75, na.rm =TRUE),0),
                     clin = stringr::str_replace_all( expr_text(col), "~","") ) %>% 
    dplyr::mutate( res = paste(median, " (", first_quantile, "-", third_quantile, ")",sep="") ) %>% 
    dplyr::select(-median, -first_quantile, - third_quantile)
  
}



create_con_table = function( df, trt_var, con_var ){
  
  trt = sym(trt_var)
  df_non_case = df %>%
    dplyr::filter( !!trt ==0)
  
  df_case = df %>%
    dplyr::filter( !!trt ==1)
  
  df_total = df
  
  col = con_var
  col = syms(col)
  
  summary_non_case_con = purrr::map_dfr( col, summary_for_con, data=df_non_case)
  summary_case_con = purrr::map_dfr( col, summary_for_con, data=df_case)
  summary_total_con = purrr::map_dfr( col, summary_for_con, data=df_total)
  
  con_table = summary_non_case_con %>%
    dplyr::left_join( summary_case_con, by = "clin") %>% 
    dplyr::left_join(summary_total_con, by ="clin")
  
  
  names(con_table) = c("clin","non_cases","cases","Total")
  
  return(con_table)
  
}


## part 4 get_cat_stats

get_cat_stats = function( df, trt, cat_var ){
  
  ID_var =  grep( "ID|id|Id", names(df), value = T )
  ID_var = sym(ID_var)
  trt_var = sym(trt)
  
  cat_stats = df %>% 
    dplyr::select( !!ID_var, !!trt_var, everything()) %>% 
    tidyr::gather(key="clin", value="clin_value", - !!ID_var, - !!trt_var ) %>% 
    tidyr::nest(-clin)%>% 
    dplyr::mutate( test = purrr::map(.$data, ~chisq.test(.x[trt], .x$clin_value))) %>% 
    dplyr::mutate( p = purrr::map_dbl(.$test, ~.x$p.value)) %>% 
    dplyr::select(clin, p)
  
  return( cat_stats)
  
  
}



## part 5 get_con_stats
get_con_stats = function( df, trt, con_var ){
  
  ID_var =  grep( "ID|id|Id", names(df), value = T )
  ID_var = sym(ID_var)
  trt_var = sym(trt)
  
  con_stats = df %>% 
    dplyr::select( !!ID_var, !!trt_var, everything()) %>% 
    tidyr::gather(key="clin", value="clin_value", - !!ID_var, - !!trt_var ) %>% 
    tidyr::nest(-clin)%>% 
    dplyr::mutate( test = purrr::map(.$data, ~t.test(.x$clin_value~ unlist(.x[trt]  )))) %>% 
    dplyr::mutate( p = purrr::map_dbl(.$test, ~.x$p.value)) %>% 
    dplyr::select(clin, p)
  
  return( con_stats)
  
}



## part 6, combine all, the main function

get_table1 = function( df, trt) {
  
  variables = get_con_cat_var(df)
  
  cat_table = create_cat_table( df, trt, variables[[1]] )
  
  con_table = create_con_table( df, trt, variables[[2]] )
  
  cat_stats = get_cat_stats ( df, trt, variables[[1]])
  
  con_stats = get_con_stats ( df, trt, variables[[2]])
  
  df_for_con = con_table %>% 
    dplyr::left_join( con_stats, by ="clin")
  
  df_for_cat = cat_table %>% 
    dplyr::left_join( cat_stats, by ="clin")
  
  df_report = dplyr::bind_rows( df_for_con, df_for_cat)
  
  return(df_report)
  
  
}