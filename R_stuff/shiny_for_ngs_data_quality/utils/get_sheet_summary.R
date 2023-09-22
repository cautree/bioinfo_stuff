library(dplyr)



read_sheet <- function(x,y){
  
  csv = readxl::read_excel(x, sheet=y)
  return(csv)
}



get_mean_pct_perfect_plate <- function(x){
  mean_perfect = mean(x$`% Perfectbarcode`, na.rm=T)
  mean_perfect = round(mean_perfect, 3)
  return(mean_perfect)
}



get_mean_pct_One_mismatchbarcode_plate<- function(x){
  
  mean_q_score = mean(x$`% One mismatchbarcode`, na.rm=T )
  mean_q_score = round(mean_q_score,3)
  return(mean_q_score)
}

get_mean_pct_Q30bases_plate<- function(x){
  
  mean_q_score = mean(x$`% >= Q30bases`, na.rm=T )
  mean_q_score = round(mean_q_score,3)
  return(mean_q_score)
}

get_cv_pct_of_the_plate <- function(x){
  
  sd_q_score = sd(x$`% of the plate`, na.rm=T )
  mean_q_score = mean(x$`% of the plate`, na.rm=T )
  cv = sd_q_score*100/mean_q_score
  cv = round(cv, 3)
  return(cv)
}


get_sheet_summary_reports <- function(all_sheets){
  
  print("=======================================in get_sheet_summary_reports")
  
  path <- all_sheets$path
  sheet <- all_sheets$sheets
  
  ngs <- purrr::map2( path, sheet, read_sheet )
  
  cv_pct_of_the_plate <- purrr::map_dbl( ngs, get_cv_pct_of_the_plate)
  mean_pct_perfect_plate <-  purrr::map_dbl( ngs, get_mean_pct_perfect_plate)
  mean_pct_One_mismatchbarcode_plate <- purrr::map_dbl( ngs, get_mean_pct_One_mismatchbarcode_plate)
  mean_pct_Q30bases_plate <- purrr::map_dbl( ngs, get_mean_pct_Q30bases_plate)
  
  report <- data.frame( run_name = all_sheets$run_name,
                        run_plate_name = all_sheets$run_pb, 
                        mean_pct_perfect_plate = mean_pct_perfect_plate,
                        mean_pct_One_mismatchbarcode_plate = mean_pct_One_mismatchbarcode_plate,
                        mean_pct_Q30bases_plate =mean_pct_Q30bases_plate,
                        cv_pct_of_the_plate = cv_pct_of_the_plate,
                        stringsAsFactors = F)
  return(report)
  
}



