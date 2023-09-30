library(sva)

#log transform, centered to median, sd =1, default is remove missing bigger than 20%
get_normalized_data = function(df_meta, missing_threshold =0.2) {
  
  df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]
  df_info = df_meta[ names(df_meta)[!grepl("[0-9]", names(df_meta))] ]
  
  #remove more than 20% missing
  df_data <- df_data[,colSums(is.na(df_data))< nrow(df_data)* missing_threshold]
  
  df_data = as.data.frame(apply( df_data,
                                 2,
                                 function(y) ( log(y) - median(log(y), na.rm = T))/ sd( log(y), na.rm = T)))
  
  res = dplyr::bind_cols( df_info, df_data)
  return(res)
  
}

NA2mean <- function(x) replace(x, is.na(x), min(x, na.rm = TRUE)*0.25)

get_imputated_sample= function(df_meta,  missing_threshold =0.2){
  
  ##get meta data, which has number in the name
  df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]
  ##get other info data, which do not have number in the name
  df_info = df_meta[ names(df_meta)[!grepl("[0-9]", names(df_meta))] ]
  
  #remove more than 20% missing
  df_data <- df_data[,colSums(is.na(df_data))< nrow(df_data)*missing_threshold]
  df_data[] <- lapply(df_data, NA2mean)
  
  res = dplyr::bind_cols( df_info, df_data)
  return(res)
  
}


na_of_metabolites = function( df_meta ){
  
    ##get meta data, which has number in the name
    df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]

    na_count = as.data.frame(sapply( df_data, function(y) sum(length(which(is.na(y))))))
    
    names(na_count) ="NA_count"
    na_count = na_count %>%
      tibble::rownames_to_column(var = "meta") %>% 
      dplyr::arrange(NA_count)
    
    return( na_count)
     
}


get_metabolites_mean_sd_CV = function( df_meta ){
  
  ##get meta data, which has number in the name
  df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]
  
  sd_val <- as.data.frame(sapply(df_data, sd, na.rm = T))
  names(sd_val) = "sd"
  sd_val = sd_val %>% 
    tibble::rownames_to_column( var = "meta")
  
  mean_val = as.data.frame(sapply( df_data, mean, na.rm =T))
  names(mean_val) = "mean"
  mean_val = mean_val %>% 
    tibble::rownames_to_column( var = "meta")
  
  res <- sd_val %>% 
    dplyr::left_join( mean_val, by = "meta") %>% 
    dplyr::mutate( CV = sd/mean) %>% 
    dplyr::arrange(CV)

  return(res)
  
}


get_metabolites_moving_median = function( df_meta ){
  
  ##meta name is like 300004_2.01_40000
  meta_name =  grep(  "[0-9]{2,}$"  , names(df_meta), value=T ) 
  
  df_meta = df_meta[ c("plate_well", meta_name)]
  df_meta = as.data.frame(df_meta)
  rownames(df_meta) = df_meta$plate_well
  df_meta$plate_well = NULL
  df_mv_median = as.data.frame(apply( df_meta, 1, median, na.rm=T))
  names(df_mv_median) = "well_median"
  
  df_mv_median = df_mv_median %>% 
    tibble::rownames_to_column( var = "plate_well") %>% 
    tidyr::separate(plate_well, c("plate", "well"), convert=T, remove =T) %>%
    dplyr::mutate(order =(plate-1)*96+well )%>%
    dplyr::select( -plate, -well) %>% 
    dplyr::select( order, well_median)
  
  return(df_mv_median)
  
}


get_combat_corrected_data= function(df_meta, missing_threshold){
  force(missing_threshold)
  df_meta = get_imputated_sample(df_meta,  missing_threshold)
  df_meta = get_normalized_data(df_meta)
  
  df_info = df_meta[ names(df_meta)[!grepl("[0-9]", names(df_meta))] ]
  df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]
  
  df_info = df_info %>%
    tidyr::separate( plate_well, c("plate", "well"), sep="_", remove = FALSE) %>%
    dplyr::mutate(plate = as.numeric(plate))
  
  batch = df_info$plate
  
  edata = df_meta[names(df_meta) %in% c('plate_well', names(df_data))]
  
  rownames(edata) = edata$plate_well
  edata$plate_well = NULL
  
  edata = t(edata)
  
  combat_edata = ComBat(dat=edata, batch=batch, mod=NULL, par.prior=TRUE, prior.plots=FALSE)
  combat_edata = as.data.frame(t(combat_edata))
  
  res = dplyr::bind_cols(df_info, combat_edata)
  
  res =res %>%
    dplyr::select(-plate, -well) %>%
    dplyr::select(subjectId, plate_well, everything())
  
  return(res)
  
}




lm_model = function(x){
  
  lm(meta_reading ~ plate, data =x)
}


get_residual_corrected_data = function( df_meta , missing_threshold) {
  force(missing_threshold)
  
  df_info =  df_meta[ names(df_meta)[ !grepl("[0-9]", names(df_meta))] ]
  
  df_meta = get_imputated_sample (df_meta, missing_threshold)
  
  df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]
  
  df_data = df_meta[ c("plate_well", names(df_data))]
  
  df = df_data %>%
    tidyr::gather( key="mzid", value= "meta_reading", -plate_well) %>%
    tidyr::separate(plate_well, c( "plate", "well"), sep="_", remove = FALSE) %>% 
    dplyr::select(-well) %>%
    dplyr::select(plate_well, plate, everything()) %>%
    tidyr::nest(-mzid) %>%
    dplyr::mutate( mod1 = purrr::map(.$data, ~lm_model(.x))) %>%
    dplyr::mutate(tidy_mod1 = purrr::map(.$mod1, ~broom::augment(.x))) %>%
    dplyr::mutate(res = purrr::map2(.$data, .$tidy_mod1, function(x,y){
      ## original data for late compare
      x_s = x %>%
        dplyr::rename(orig_plate = plate,
                      orig_meta_reading = meta_reading)
      ## residualized data, and original data
      y_s = y %>%
        dplyr::select(meta_reading, plate, .resid)
      
      z = dplyr::bind_cols(x_s, y_s)
      return(z)
      
    }) )%>% 
    dplyr::select(mzid, res) %>%
    tidyr::unnest() # can check for the original data and corrected ones matched well or not
  
  
  df_corrected = df %>%
    dplyr::select(mzid, plate_well, .resid) %>%
    tidyr::spread( key= mzid, value=.resid) %>% 
    dplyr::left_join( df_info) %>% 
    dplyr::select( plate_well, subjectId, year, everything())
  
  return(df_corrected)
  
}
