library(dplyr)
library(readxl)
library(tidyr)


###########################################################
# this is for reagent i5 projects
# first parameter is group number, telling which folder to get the excel report
# second parameter is the excel sheets counts with FASTQ
# test runs are:
# Rscript scripts/auto_detect_outliers_UDI.R group2 1
# Rscript scripts/auto_detect_outliers_UDI.R group4 1
# Rscript scripts/auto_detect_outliers_UDI.R group6 1
###########################################################

args = commandArgs(trailingOnly=TRUE)
group_number = args[1]
file_count = args[2]

#group_number = "group6"
#file_count = "1"


file_count = as.integer(file_count)


group_path = paste("data/", group_number, sep="")
path_list1 = list.files( group_path )
fold_path = paste( group_path, path_list1, sep="/" )


sheet_list = purrr::map( fold_path, readxl::excel_sheets )

grep_function = function(x){
  res = grep( "_FASTQ",x, value =T)
  return(res)
}

fastq_sheet_list = unlist(purrr::map( sheet_list,grep_function  ))


file = rep(fold_path,each=file_count)
file = as.character(ordered(file))


fastq_sheet_list_df = data.frame( fastq_sheet = fastq_sheet_list,
                                  stringsAsFactors = F)
## remove the one that only appeared once


fastq_sheet_list_df = fastq_sheet_list_df %>% 
  dplyr::mutate( fastq = stringr::str_replace_all(fastq_sheet_list, "set", "")) %>% 
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
  
  info_df = data.frame( excel_path = file,
                        sheet_name = fastq_sheet_list,
                        stringsAsFactors = F
  )
  
}else{
  
  info_df = data.frame( excel_path = file,
                        sheet_name = fastq_sheet_list_df$fastq_sheet,
                        stringsAsFactors = F )
  
  
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


print(info_df)

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


readr::write_csv(df_table_s,  paste("results/", group_number, "_report_of_outliers_in_each_position.csv", sep="" ) )
