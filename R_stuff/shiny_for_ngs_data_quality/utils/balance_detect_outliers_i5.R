library(dplyr)
library(readxl)



grep_function = function(x){
  res = grep( "_FASTQ",x, value =T)
  return(res)
}





read_data_function_i5 = function(x, y){
  
  df = readxl::read_excel( x, sheet = y)
  
  df_s = df %>% 
    select(  well, `PF Clusters` , `% of the plate`) %>% 
    rename( PF_Clusters = `PF Clusters`,
            pct_of_plate = `% of the plate` ) %>% 
    mutate( run_name = stringr::str_extract(x, "\\d{8}_[A-Za-z]{5,}-[A-Za-z]{4}")) %>% 
    mutate( i5 = stringr::str_extract(y, "[A-Z]\\d{2}")) %>% 
    select( run_name, i5, well, PF_Clusters, pct_of_plate )
  
  return(df_s)
}





get_i5_outlier = function(group_number){
  group_number = as.integer(group_number)
  
  print(head(balance_info))
  print( sapply(balance_info, class))
   
  balance_info_s = balance_info %>% 
    dplyr::filter( group == group_number  ) %>% 
    dplyr::filter( ! grepl("PB",sheets ) )
  
  
  
  info_df = data.frame( excel_path = balance_info_s$path,
                        sheet_name = balance_info_s$sheets,
                        stringsAsFactors = F
  )
  
  
  
  df = purrr::map2_dfr( info_df$excel_path, info_df$sheet_name, read_data_function_i5 )
  
  df_pp = df %>% 
    tidyr::nest( -c(run_name, i5 )  ) %>% 
    mutate( data2 = purrr::map(.$data, function(x){
      mean_plate = mean(x$pct_of_plate, na.rm =T)  
      median_plate = median(x$pct_of_plate, na.rm = T)  
      sd_plate = sd(x$pct_of_plate, na.rm =T) 
      x = x %>% 
        mutate( super_high_low = ifelse(   (pct_of_plate >  1.3333*mean_plate) | (pct_of_plate < 0.6667*mean_plate)  , 1, 0 ) ) 
      return(x)
      
    })) %>% 
    select( run_name, i5, data2) %>% 
    tidyr::unnest() 
  
  
  df_table = df_pp %>% 
    tidyr::nest( -run_name) %>% 
    mutate( data2 = purrr::map(.$data, function(x){
      
      y = x %>% 
        filter( super_high_low ==1)
      z = table(y$well, y$i5)
      z = as.data.frame(z)
      
      
      z = z %>% 
        tidyr::spread( Var2, Freq)
      names(z)[1] = "well"
      return(z)
      
    })) %>% 
    select(run_name, data2 ) %>% 
    tidyr::unnest()
  
  print(head(df_table))
  
  df_table_s = df_table %>% 
    tidyr::gather( E08: F09, key="i5", value = "outlier_flag") %>% 
    tidyr::nest( -c(well, i5)) %>% 
    mutate( outlier_counts = purrr::map_dbl(.$data, function(x){
      
      sum = sum(x$outlier_flag, na.rm =T)
      x = x %>% 
        mutate( outlier_n = sum) %>% 
        select( -outlier_flag, -run_name) %>% 
        distinct() %>% 
        pull( outlier_n)
      return(x)
    })) %>% 
    dplyr::select( well, i5, outlier_counts) %>% 
    tidyr::unnest()
  
  print(head(df_table_s))
  
  
  df_table_report = df_table_s %>% 
    tidyr::spread( i5, outlier_counts )
  
  print(head(df_table_report))
  
  return(df_table_report)
}


