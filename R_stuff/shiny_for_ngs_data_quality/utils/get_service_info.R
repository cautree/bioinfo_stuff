library(dplyr)
library(lubridate)


run_names = list.files("data/services/")

service_df = data.frame( run_name  = run_names, stringsAsFactors = F )
service_df <- service_df %>% 
  tidyr::separate( run_name, c("date", "Sequencer"), sep="_", remove = F) %>% 
  dplyr::mutate( date = lubridate::as_date(date))

readr::write_csv( service_df, "info/service_info.csv")