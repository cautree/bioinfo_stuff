library(dplyr)
library(readxl)

print("=====================================in get crosstalk info")
files_name <- list.files("data/crosstalk/")
files_path <- paste("data/crosstalk/", files_name, sep="")


info_df0 <- data.frame( path = files_path, stringsAsFactors = F)
info_df0

info_df <- info_df0 %>% 
  tidyr::separate( path, c("date","Sequencer","a","b"), sep="_", remove =F) %>% 
  dplyr::mutate( date = stringr::str_replace_all(date, "data/crosstalk/", "")) %>% 
  dplyr::mutate( run_name = paste(date,Sequencer,a, sep="_")) %>% 
  dplyr::mutate( date = lubridate::as_date(date)) %>% 
  dplyr::select(-a, -b) 



readr::write_csv( info_df, "info/crosstalk_info.csv")

