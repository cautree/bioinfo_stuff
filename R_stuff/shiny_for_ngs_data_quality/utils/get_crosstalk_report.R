library(scales)
library(RColorBrewer)
library(pheatmap)

get_crosstalk_summary =function( run_name_input){
  
  crosstalking_info = crosstalking_info %>% 
    dplyr::filter( run_name == run_name_input)
  path = unique(crosstalking_info$path )
  df = readr::read_csv(path)
  
  well_n = nrow(df)
  
  df = as.data.frame( df)
  rownames(df) = df$i7
  df$i7 = NULL
  all_reads_total_count = sum(df)
  
  good_reads_count = sum(diag(as.matrix(df)))
  good_reads_count_pct = round(good_reads_count*100/all_reads_total_count,3)
  good_reads_well_avg = round(sum(diag(as.matrix(df)))/well_n,3)
  good_reads_well_sd = round(sd(diag(as.matrix(df))),3)
  
  bad_df = as.matrix(df)
  diag(bad_df )  = NA
  bad_reads_count = sum(bad_df, na.rm = T)
  bad_reads_count_pct = round(bad_reads_count*100/all_reads_total_count,3)
  bad_reads_avg = round(sum(bad_df, na.rm = T) / (well_n*(well_n-1)),3)
  bad_reads_sd = round(sd(bad_df, na.rm = T),3)
  
  Correct_Barcode_Combinations = tibble(      group = "Correct_Barcode_Combinations",
                                              Total_Reads = good_reads_count,
                                              `% of Total Reads` = good_reads_count_pct,
                                              `Average Reads` = good_reads_well_avg,
                                              `Standard Deviation` = good_reads_well_sd)
  
  Incorrect_Barcode_Combinations = tibble( group = "Incorrect_Barcode_Combinations",
                                           Total_Reads = bad_reads_count,
                                           `% of Total Reads` = bad_reads_count_pct,
                                           `Average Reads` = bad_reads_avg,
                                           `Standard Deviation` = bad_reads_sd)
  
  two_combined = tibble( group = "all_Barcode_Combinations",
                         Total_Reads = all_reads_total_count,
                         `% of Total Reads` = NA,
                         `Average Reads` = NA,
                         `Standard Deviation` = NA)
  
  summary_df = dplyr::bind_rows( Correct_Barcode_Combinations, Incorrect_Barcode_Combinations, two_combined)
  
  return(summary_df)
  
}



get_crosstalk_i5_boxplot = function( run_name_input) {
  
  crosstalking_info = crosstalking_info %>% 
    dplyr::filter( run_name == run_name_input)
  path = unique(crosstalking_info$path )
  
  df = readr::read_csv(path)
  df = as.data.frame( df)
  rownames(df) = df$i7
  df$i7 = NULL
  all_reads_total_count = sum(df)
  
  good_df = as.data.frame(diag(as.matrix(df)))
  names(good_df) = "Correct_Barcode_Combinations"
  good_df = good_df %>% 
    dplyr::add_rownames(var = "i5")
  
  good_mean = mean(good_df$Correct_Barcode_Combinations,na.rm=T) + 1000
  
  bad_df  = as.matrix(df)
  diag(bad_df )  = NA
  bad_df = as.data.frame( bad_df)
  
  nr = nrow(bad_df)
  r_name = rownames(bad_df)
  r_name_start = r_name[[1]]
  r_name_stop = r_name[[ nr]]
  
  bad_df_long = bad_df %>% 
    dplyr::add_rownames( var = "i7") %>% 
    dplyr::mutate( i7 = paste("i7", i7, sep="_")) %>% 
    tidyr::gather( r_name_start: r_name_stop, key="i5", value = "Incorrect_Barcode_Combinations") %>% 
    dplyr::filter( !is.na(Incorrect_Barcode_Combinations))
  
  df_combined = bad_df_long %>% 
    dplyr::left_join( good_df, by = "i5")
  
  n = round(all_reads_total_count*0.001*(96/nr),0)
  
  p = df_combined %>% 
    ggplot()+ 
    geom_boxplot(aes(i5, Incorrect_Barcode_Combinations )) +
    geom_point( aes(i5, Correct_Barcode_Combinations)) +
    scale_y_log10(labels = comma) +
    geom_hline(yintercept=n,linetype=2, color = "red") +
    geom_text(aes(20,n,label = paste("0.1% threshold,", n, "reads",sep=" "), vjust = -1, color = "red")) +
    geom_text(aes(20,good_mean,label = "correct barcodes", vjust = -1)) +
    ylab("Reads") +
    xlab("I5-TR") +
    theme(axis.text.x = element_text(angle = 90))+
    guides(color = FALSE)
  
  
  return(p)
  
}



get_crosstalk_data = function(run_name_input){
  
  crosstalking_info = crosstalking_info %>% 
    dplyr::filter( run_name == run_name_input)
  path = unique(crosstalking_info$path )
  
  df = readr::read_csv(path)
  df = as.data.frame( df)
  rownames(df) = df$i7
  df$i7 = NULL
  return(df)
  
}



