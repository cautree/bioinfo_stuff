library(dplyr)
library(readxl)

print("=====================================in get wgs info")
files_name <- list.files("data/wgs/")
files_path <- paste("data/wgs/", files_name, sep="")


info_df0 <- data.frame( path = files_path, stringsAsFactors = F)
info_df0

info_df <- info_df0 %>% 
  tidyr::separate( path, c("date","Sequencer","a","b"), sep="_", remove =F) %>% 
  dplyr::mutate( date = stringr::str_replace_all(date, "data/wgs/", "")) %>% 
  dplyr::mutate( run_name = paste(date,Sequencer, sep="_")) %>% 
  dplyr::mutate( date = lubridate::as_date(date)) %>% 
  dplyr::select(-a, -b) 



readr::write_csv( info_df, "info/wgs_info.csv")


