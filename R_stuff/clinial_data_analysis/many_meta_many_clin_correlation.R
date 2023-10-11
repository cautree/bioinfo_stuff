pSpearman = function(df){
  
  mod = PResiduals::partial_Spearman(meta_reading| clin_reading ~ age+sex+drug,data=df)
  return(mod)
  
}

jupiter_pSpearman_mod = jupiter %>% 
  tidyr::gather( `delta_Taurochenodeoxycholic a.`: `delta_VLCDCA_34`,  key="meta",   value = "meta_reading") %>% 
  tidyr::gather( ldlc_delta:chol_delta, key="clin", value="clin_reading" ) %>% 
  tidyr::nest( -c(meta,  clin)) %>% 
  dplyr::mutate( mod = purrr::map(data, pSpearman)) %>% 
  dplyr::mutate( mod_cor = purrr::map_dbl(.$mod, function(x){
    y = x$TS$TB$ts
    return(y)
  })) %>% 
  dplyr::mutate( mod_p = purrr::map_dbl(.$mod, function(x){
    y = x$TS$TB$pval
    return(y)
  }))  %>% 
  dplyr::select( meta, clin, mod_cor, mod_P)