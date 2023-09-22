library(aws.s3)
library(dplyr)

#https://www.gormanalysis.com/blog/connecting-to-aws-s3-with-r/





files_in_s3 <- get_bucket_df(
  bucket = "s3://seqwell-dashboard/", 
  prefix = "services",
  region = "us-east-1", 
  max = 1000
) %>% 
  as_tibble() %>% 
  dplyr::filter( grepl("services/", Key)) %>% 
  dplyr::pull(Key)



files_in_shiny <- paste("services/" , list.files(path="data/services", recursive = T), sep="")
files_in_shiny



to_get_from_s3 <- setdiff(files_in_s3, files_in_shiny )
to_get_from_s3 <- to_get_from_s3[ grep("[txt|csv]", to_get_from_s3)]


save_files <- function(file) {
  
  # if object doesn't exist in bucket, return NA
  ok <- object_exists(
    object = file,
    bucket = "s3://seqwell-dashboard/", 
    prefix = "services",
    region = "us-east-1"
  )
  if(!ok) return(NA_character_)
  
  # if object exists, save it and return file path
  save_object(
    object = file,
    bucket = "s3://seqwell-dashboard/", 
    prefix = "services",
    region = "us-east-1",
    file = paste0("data/", file)
  )
}


to_get_from_s3 %>% 
  purrr::map_chr(save_files)