library(dplyr)
library(readxl)
library(tidyr)

grep_function = function(x){
  res = grep( "_FASTQ",x, value =T)
  return(res)
}


read_data_function = function(x, y){
  
  df = readxl::read_excel( x, sheet = y)
  
  df_s = df %>% 
    select(  well, `PF Clusters` , `% of the plate`) %>% 
    rename( PF_Clusters = `PF Clusters`,
            pct_of_plate = `% of the plate` ) %>% 
    mutate( run_name = stringr::str_extract(x, "\\d{8}_[A-Za-z]{5,}-[A-Za-z]{4}")) %>% 
    select( run_name,  well, PF_Clusters, pct_of_plate )
  ## removed i5
  
  return(df_s)
  
  
}



get_i7_outlier = function( group_number){
  
  group_number = as.integer(group_number)

  
  group_number = as.integer(group_number)
  
  
  print(head(balance_info))
  print( sapply(balance_info, class))
  
  balance_info_s = balance_info %>% 
    dplyr::filter( group == group_number  ) 
  
  
  fastq_sheet_list_df = data.frame( fastq_sheet = balance_info_s$sheets,
                                    stringsAsFactors = F)
  
  
  fastq_sheet_list_df = fastq_sheet_list_df %>% 
    dplyr::mutate( fastq = stringr::str_replace_all(balance_info_s$sheets, "set", "")) %>% 
    dplyr::mutate( fastq = stringr::str_extract(fastq, "\\w*_FASTQ" ))
  
  nrow = nrow(fastq_sheet_list_df)
  
  
  if (nrow>=4){
    
    high_frq_fastq = as.data.frame(table(fastq_sheet_list_df$fastq)) %>% 
      dplyr::arrange(-Freq) %>% 
      dplyr::top_n(1, Freq) %>% 
      dplyr::pull(Var1)
    
    high_frq_fastq
    fastq_sheet_list = fastq_sheet_list_df %>% 
      dplyr::filter(fastq  == high_frq_fastq) %>% 
      dplyr::pull(fastq_sheet)
    
    print(file)
    print(fastq_sheet_list)
    
    path_s = balance_info_s %>% 
      dplyr::filter( sheets %in% fastq_sheet_list) %>% 
      dplyr::pull(path)
    
    info_df = data.frame( excel_path = path_s,
                          sheet_name = fastq_sheet_list,
                          stringsAsFactors = F
    )
    
  }else{
    
    info_df = data.frame( excel_path = balance_info_s$path,
                          sheet_name = fastq_sheet_list_df$fastq_sheet,
                          stringsAsFactors = F )
    
    
  }
  
  balance_info_s$path
  fastq_sheet_list_df$fastq_sheet
  
  
  df = purrr::map2_dfr( info_df$excel_path, info_df$sheet_name, read_data_function )
  
  df_pp = df %>% 
    tidyr::nest( -c(run_name )  ) %>% 
    mutate( data2 = purrr::map(.$data, function(x){
      mean_plate = mean(x$pct_of_plate, na.rm =T)  
      median_plate = median(x$pct_of_plate, na.rm = T)  
      sd_plate = sd(x$pct_of_plate, na.rm =T) 
      x = x %>% 
        mutate( super_high_low = ifelse(   (pct_of_plate >  1.3333*mean_plate) | (pct_of_plate < 0.6667*mean_plate)  , 1, 0 ) ) 
      return(x)
      
    })) %>% 
    select( run_name, data2) %>% 
    tidyr::unnest() 
  
  
  df_table = df_pp %>% 
    tidyr::nest( -run_name) %>% 
    mutate( data2 = purrr::map(.$data, function(x){
      
      y = x %>% 
        filter( super_high_low ==1)
      z = table(y$well)
      z = as.data.frame(z)
      
      
      
      names(z)[1] = "well"
      return(z)
      
    })) %>% 
    select(run_name, data2 ) %>% 
    tidyr::unnest()
  
  
  
  df_table_s = df_table %>% 
    dplyr::select( -run_name) %>% 
    tidyr::nest(- well) %>% 
    mutate( count = purrr::map_dbl(.$data, function(x){
      n_row = nrow(x)
      return(n_row)
    })) %>% 
    dplyr::select( well, count) %>% 
    tidyr::unnest()
  
  
  return(df_table_s)
  
  
}

