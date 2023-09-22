
library(dplyr)
library(readxl)

print("=====================================in sheets info")
files_name <- list.files("data/fastq/")
files_path <- paste("data/fastq/", files_name, sep="")


info_df0 <- data.frame( path = files_path, stringsAsFactors = F)

info_df <- info_df0 %>% 
  dplyr::mutate( sheets = purrr::map( files_path, readxl::excel_sheets) ) %>% 
  tidyr::unnest() %>% 
  dplyr::filter( grepl("FASTQ",sheets)) %>% 
  tidyr::separate( path, sep="/" , c("a","run_name"), remove =F) %>% 
  dplyr::mutate( run_name = stringr::str_replace_all(run_name, ".xlsx", "")) %>% 
  dplyr::mutate(PB = stringr::str_replace_all( sheets, "_FASTQ","")) %>% 
  tidyr::separate( path, c("a","b", "run_name"), sep="/", remove =F) %>% 
  tidyr::separate( run_name, c("date", "d"), sep="_", remove =F) %>% 
  dplyr::mutate( date = lubridate::as_date(date)) %>% 
  dplyr::mutate(run_name = stringr::str_replace_all(run_name, ".xlsx", "")) %>% 
  tidyr::separate( run_name, c("e","Sequencer"), sep="_", remove = F) %>% 
  dplyr::mutate( run_pb = paste(run_name, PB, sep="_")) %>% 
  dplyr::select( -a, -b, -d, -e) 

 

readr::write_csv( info_df, "info/sheet_info.csv")


  


