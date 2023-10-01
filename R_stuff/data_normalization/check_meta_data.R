library(dplyr)


## create idenity annotation data frame and the reading data frame from the original data
meta_data_check = function( df_all, meta_name_key_word ){
  
  df_all [ is.na(df_all)] = NA
  
  df_all = df_all %>% 
    dplyr::mutate( mzrt =  paste(format(round(MZ, 4), nsmall = 4),
                                 format(round(RT, 2), nsmall = 2),
                                 local_Lab,
                                 sep ="_")  )
  
  df_identity = df_all %>% 
    dplyr::select( mzrt, local_Lab, Standards)
  
  meta_name = grep(meta_name_key_word, names(df_all), value=T)
  
  df_meta_t = df_all[ names(df_all) %in% c("mzrt", meta_name)]
  df_meta_t = as.data.frame(df_meta_t)
  rownames(df_meta_t) = df_meta_t$mzrt
  df_meta_t$mzrt = NULL
  
  df_meta = as.data.frame( t(df_meta_t))
  
  df_meta = df_meta %>% 
    tibble::rownames_to_column( var = "sample_ID")
  
  return( list( df_identity, df_meta))
  
  
}

meta_name_key_word = "LCMS_EIC_Jupiter"
df_all = data.table::fread("../../data/SPM/SPM_20230316/Jupiter_ProcessedDataNormDeadductedV2_Trimmed_MzRtPeakId(20230217T1409).csv")
df_all = as.data.frame(df_all)
res = meta_data_check (df_all, meta_name_key_word)
res[[1]]
res[[2]]
