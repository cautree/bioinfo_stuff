# year_choice: c(0,2)
# df_meta only has these non meta variables: subjectId, year, plate_well
get_delta = function(df_meta, year_choice){
  
  df_meta <- df_meta %>% 
    dplyr::filter( year %in% year_choice) %>% 
    dplyr::add_count( subjectId) %>% 
    dplyr::filter(n ==2) %>% 
    dplyr::select( -plate_well, -n) %>% 
    dplyr::arrange( subjectId)
  
  df_bl = df_meta %>%
    dplyr::filter(year ==0 ) %>% 
    dplyr::select(-year)
  
  df_y2 = df_meta %>%
    dplyr::filter(year ==2 ) %>% 
    dplyr::select(-year)
  
  df_delta = df_bl 
  df_delta[-1] = df_y2[-1] - df_bl[-1]
  
  df_delta <- df_delta %>% 
    dplyr::select(subjectId, everything())
  
  return(df_delta)
  
  
}




##trim outlier
out2_3d <- function(x) replace(x, x>(mean(x, na.rm=T) + 3*sd(x, na.rm=T)), mean(x, na.rm=T) + 3*sd(x, na.rm=T))

trim_outier_to_3d_normalized = function( df_meta ){
  
  df_data = df_meta[ names(df_meta)[grepl("[0-9]", names(df_meta))] ]
  df_info = df_meta[ names(df_meta)[!grepl("[0-9]", names(df_meta))] ]
  
  df_data[]<- lapply(df_data, out2_3d)
  
  df_data = as.data.frame(apply( df_data,
                                 2,
                                 function(y) ( y - median( y, na.rm = T))/ sd( y, na.rm = T)))
  
  df_data_transformed = dplyr::bind_cols( df_info, df_data )
  
  return( df_data_transformed)
  
}


get_linear_model_res = function(df_meta,
                                df_clinical,
                                trt_var,
                                adjustment_var =c()){
  
  
  
  df = df_meta %>%
    dplyr::inner_join(df_clinical, by = "subjectId")
  
  meta = names(df)[grepl("[0-9]", names(df))]
  
  if(  length(adjustment_var) == 0){
    
    df = df[ names(df) %in% c(meta, trt_var) ]
    variables = c(trt_var)
    
    f = as.formula(
      paste("meta_reading",
            paste(variables),
            sep = " ~ "))
    
    df_long = df %>%
      dplyr::select(trt_var, everything()) %>%
      tidyr::gather(key="meta", value="meta_reading", -variables) %>%
      tidyr::nest(data = c(variables, meta_reading))
    
  }else{
    adjustment_var = unlist(stringr::str_split(adjustment_var, " "))
    
    df =df[ names(df) %in% c(meta, trt_var, adjustment_var) ]
    variables = c(trt_var, adjustment_var)
    
    f = as.formula(
      paste("meta_reading",
            paste(variables, collapse = " + "),
            sep = " ~ "))
    
    df_long = df %>%
      dplyr::select(trt_var, adjustment_var, everything()) %>%
      tidyr::gather(key="meta", value="meta_reading", -variables) %>%
      tidyr::nest(data = c(variables, meta_reading))
  }
  
  f2 = as.formula(
    paste("meta_reading",
          paste(trt_var, collapse = " + "),
          sep = " ~ ")
  )
  
  lm_report = df_long%>%
    dplyr::mutate( model = purrr::map(.$data, ~lm(f, data =.x))) %>%
    dplyr::mutate(glance = purrr::map(model, broom::tidy, conf.int = TRUE, conf.level = 0.95)) %>%
    dplyr::select(meta, glance) %>%
    tidyr::unnest(cols= c(glance)) %>%
    dplyr::filter(term == trt_var) %>%
    dplyr::select(meta, term, estimate,conf.low, conf.high, p.value) %>%
    dplyr::arrange(p.value) %>%
    dplyr::mutate( estimate = round(estimate, 3),
                   conf.low = round(conf.low, 3),
                   conf.high = round(conf.high, 3))
  
  #if trt_var is a categorical variable, also do a wilcox test
  if(length( unique(df_clinical[[trt_var]])) ==2 ){
    wilcox_report = df_long %>%
      dplyr::mutate( test = purrr::map(.$data, ~wilcox.test(f2, data =.x ))) %>%
      dplyr::mutate( wilcox_p_value = purrr::map_dbl(.$test, ~.x$p.value)) %>%
      dplyr::mutate( p.adjust =p.adjust(wilcox_p_value, method = "fdr") ) %>%
      dplyr::select(meta, wilcox_p_value, p.adjust)
    
    report = wilcox_report %>%
      dplyr::left_join(lm_report, by ="meta") %>%
      dplyr::arrange( p.adjust)
    
    readr::write_csv( report, "lm_report.csv")
    
    return(report)
  }else{
    
    readr::write_csv( lm_report, "lm_report.csv")
    return(lm_report)
    
  }
}





df_meta <- data.table::fread("ctsc_7743_20%_cleaned_w_impute_wo_outlier_removal.csv")
df_meta = as.data.frame(df_meta)
df_delta = get_delta(df_meta, c(0,2))
df_delta_norm = trim_outier_to_3d_normalized(df_delta)


df_clinical = readr::read_csv("ctsc_clin_for_test.csv")
df_result = get_linear_model_res( df_delta_norm, df_clinical, "fishoilactive", 
                                  c("age_at_rando" , "gender", "vitdactive" ,   "race_3cat"))

