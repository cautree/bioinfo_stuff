# define some credentials



library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)
library(shinymanager)



source("utils/load_data_from_s3.R")
#source("utils/load_wgs_data_from_s3.R")
source("utils/load_service_data_from_s3.R")

sub_dir1 = "info"
if (!file.exists(sub_dir1)){
  dir.create(file.path( sub_dir1))
} 

sub_dir2 = "data"
if (!file.exists(sub_dir2)){
  dir.create(file.path( sub_dir2))
} 



source("utils/get_run_info.R")
#source("utils/get_wgs_info.R")
source("utils/get_run_summary.R")
source("utils/get_sheets_info.R")
source("utils/get_sheet_summary.R")
source("utils/get_plate_barplot.R")
source("utils/get_plate_summary_barplot.R")
source("utils/helper.R")
#source("utils/get_wgs_summary.R")
#source("utils/get_wgs_barplot.R")
source("utils/get_service_summary.R")
source("utils/get_service_info.R")
source("utils/get_balancing_summary.R")
source("utils/calculate_balancing.R")
source("utils/get_crosstalk_report.R")
source("utils/balance_detect_outliers_i5.R")
source("utils/balance_detect_outliers_i7.R")



sample_info <- readr::read_csv("info/sheet_info.csv")
run_info <- readr::read_csv("info/run_info.csv")
meta_info <- readr::read_csv("meta_data/meta_data.csv")
wgs_info <- readr::read_csv("info/wgs_info.csv")
service_info <- readr::read_csv("info/service_info.csv")
balancing_info <- readr::read_csv("info/balancing_info.csv")
balancing_calculation_info <- readr::read_csv("info/balancing_calculation_info.csv")
crosstalking_info <- readr::read_csv("info/crosstalk_info.csv")
density_info <- readr::read_csv("info/miseq_density_info.csv")
occupency_info <- readr::read_csv("info/nextseq_occupency_info.csv")

balance_info  <- readr::read_csv("meta_data/Shortlist_of_Balancing_Runs.csv")
balance_info = balance_info %>% 
  dplyr::left_join( sample_info, by = "run_name")



#gindex = grep("SCR", sample_info$PB)
#ss = sample_info[ gindex,]
