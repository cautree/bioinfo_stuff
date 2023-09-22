library(dplyr)
library(readxl)

print("=====================================in sheets info")
list.files()
files_name <- list.files("data/fastq/")
files_path <- paste("data/fastq/", files_name, sep="")


info_df0 <- data.frame( path = files_path, stringsAsFactors = F)

#Full Lane Summary
info_df <- info_df0 %>% 
  dplyr::mutate( sheets = purrr::map( files_path, readxl::excel_sheets) ) %>% 
  tidyr::unnest( cols = c(sheets)) %>% 
  dplyr::filter( grepl("Full Lane Summary",sheets)) %>% 
  tidyr::separate(path, c("a","b", "run_name"), sep="/", remove =F ) %>% 
  dplyr::mutate( run_name = stringr::str_replace_all(run_name, ".xlsx", "")) %>% 
  tidyr::separate( run_name, c("date", "d"), sep="_", remove =F) %>% 
  dplyr::mutate( date = lubridate::as_date(date)) %>% 
  tidyr::separate( run_name, c("e","Sequencer"), sep="_", remove = F) %>% 
  dplyr::select( -a, -b, -d, -e) 



readr::write_csv( info_df, "info/run_info.csv")


