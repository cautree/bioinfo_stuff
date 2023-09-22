library(dplyr)



get_balancing_calculation <- function(x , Current_Volume_mL_ = 10, Stock_Conc_ = 200, SB_Conc_nM_ = 8){
  
  theoretical_avg = 1/96
  Current_Volume_mL = Current_Volume_mL_
  Stock_Conc = Stock_Conc_
  SB_Conc_nM = SB_Conc_nM_
  
  calculation_df = balancing_calculation_info %>% 
    dplyr::filter( run_name == x)
  y = unique(calculation_df$path)
  z = calculation_df$sheet
  csv1 = readxl::read_excel(y, sheet=z[[1]]) %>% 
    dplyr::select(well, `% of the plate` ) %>% 
    dplyr::rename( Library1 = `% of the plate`) %>% 
    dplyr::mutate( Library1 = Library1/100)
  csv2 = readxl::read_excel(y, sheet=z[[2]]) %>% 
    dplyr::select(well, `% of the plate` ) %>% 
    dplyr::rename( Library2 = `% of the plate`) %>% 
    dplyr::mutate( Library2 = Library2/100)
  csv3 = readxl::read_excel(y, sheet=z[[3]]) %>% 
    dplyr::select(well, `% of the plate` ) %>% 
    dplyr::rename( Library3 = `% of the plate`) %>% 
    dplyr::mutate( Library3 = Library3/100)
  
  #1000*((((Q5*B5)*I5)-(Q5*B5))/R5)
  # Current Volume (mL)
  # 1000*((((`Current Volume (mL)`*`SB Conc. (nM)`)*`Actual Adjustement`)-(`Current Volume (mL)`*`SB Conc. (nM)`))/`Stock Conc.`)
  csv = csv1 %>% 
    dplyr::inner_join( csv2, by = "well") %>% 
    dplyr::inner_join( csv3, by = "well") %>% 
    dplyr::mutate( average = round( (Library1 + Library2 + Library3  )/3,  4) ) %>% 
    dplyr::mutate( `Auto-generated Adjustment factor` = theoretical_avg/average) %>% 
    dplyr::mutate( Dilute = ifelse(`Auto-generated Adjustment factor` < 1, "Dilute", "")) %>% 
    dplyr::mutate( Supercharge = ifelse(`Auto-generated Adjustment factor` > 1, "Supercharge", "")) %>% 
    dplyr::mutate( `SB Conc. (nM)` = SB_Conc_nM) %>% 
    dplyr::mutate( `Next Round SB Conc. (nM)` = `Auto-generated Adjustment factor`*`SB Conc. (nM)`) %>% 
    dplyr::mutate(`Current Volume (mL)` = Current_Volume_mL) %>% 
    dplyr::mutate(`Stock Conc.` = Stock_Conc) %>% 
    dplyr::mutate( `Volume MTSB (ml)`  = `Current Volume (mL)`/`Auto-generated Adjustment factor`  -`Current Volume (mL)` ) %>% 
    dplyr::mutate( `Volume MTSB (ul)` =  1000*`Volume MTSB (ml)` ) %>% 
    dplyr::mutate(`Volume Stock (µl)` = 1000*((((`Current Volume (mL)`*`SB Conc. (nM)`)*`Auto-generated Adjustment factor`)-(`Current Volume (mL)`*`SB Conc. (nM)`))/`Stock Conc.`)) %>% 
    dplyr::mutate( `Volume MTSB (ml)` = ifelse( Dilute=="", NA, `Volume MTSB (ml)`)) %>% 
    dplyr::mutate( `Volume MTSB (ul)` = ifelse( Dilute=="", NA, `Volume MTSB (ul)`)) %>% 
    dplyr::mutate( `Volume Stock (µl)` = ifelse( Supercharge=="", NA, `Volume Stock (µl)`)) %>% 
    dplyr::mutate( `Auto-generated Adjustment factor` = round(`Auto-generated Adjustment factor`,2)) %>% 
    dplyr::mutate( `Next Round SB Conc. (nM)` = round(`Next Round SB Conc. (nM)`,4 )) %>% 
    dplyr::mutate( `Volume MTSB (ml)` = round(`Volume MTSB (ml)`,4 )) %>% 
    dplyr::mutate( `Volume MTSB (ul)` = round( `Volume MTSB (ul)`,4)) %>% 
    dplyr::mutate( `Volume Stock (µl)` = round(`Volume Stock (µl)`, 4)) 
  
  next_round_sb_conc_avg = mean(csv$`Next Round SB Conc. (nM)`, na.rm=TRUE)
 
  
  return( list(res = csv, avg = next_round_sb_conc_avg ))
  
  
  
}
