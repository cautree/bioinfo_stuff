get_wgs_summary <- function( path, run_name){
  
  df1 <- readxl::read_excel(path, sheet = "CollectAlignmentSummaryMetrics") 
  names(df1)[1] = "sample_ID"
  df1 <- df1 %>% 
    dplyr::select( sample_ID, PCT_PF_READS_ALIGNED , PCT_PF_READS_IMPROPER_PAIRS, PCT_CHIMERAS) %>% 
    dplyr::mutate( run_name = run_name)
  
  df2 <- readxl::read_excel(path, sheet = "CollectInsertSizeMetrics")
  names(df2)[1] = "sample_ID"
  df2 <- df2 %>% 
    dplyr::select( sample_ID, MEAN_INSERT_SIZE, MEDIAN_ABSOLUTE_DEVIATION,  MIN_INSERT_SIZE,  MAX_INSERT_SIZE)
  
  df3 <- readxl::read_excel(path, sheet = "MarkDuplicates")
  names(df3)[1] = "sample_ID"
  df3 <- df3 %>% 
    dplyr::select( sample_ID, PERCENT_DUPLICATION)
  
  df4 <- readxl::read_excel(path, sheet = "CollectGcBiasMetrics")
  names(df4)[1] = "sample_ID"
  df4 <- df4 %>% 
    dplyr::select( sample_ID, AT_DROPOUT,  GC_DROPOUT)
  
  df_wgs <- df1 %>% 
    dplyr::left_join(df2, by="sample_ID") %>% 
    dplyr::left_join(df3, by="sample_ID") %>%
    dplyr::left_join(df4, by="sample_ID") %>% 
    dplyr::select(run_name, sample_ID,  everything())
  
  df_summary = as.data.frame(purrr::map(df_wgs[-c(1:2)], mean))
  df_summary <- df_summary %>% 
    dplyr::mutate( run_name = run_name) %>% 
    dplyr::select(run_name, everything())
  
  df_summary[-1][] <- sapply(df_summary[-1], round,5)
  
  return( df_summary )
 
  
}