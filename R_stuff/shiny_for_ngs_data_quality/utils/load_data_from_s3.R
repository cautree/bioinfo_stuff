library(aws.s3)
library(dplyr)

#https://www.gormanalysis.com/blog/connecting-to-aws-s3-with-r/




excel_files_in_s3 <- get_bucket_df(
  bucket = "s3://seqwell-dashboard/", 
  prefix = "fastq",
  region = "us-east-1", 
  max = 1000
) %>% 
  as_tibble() %>% 
  dplyr::filter( grepl("fastq/", Key)) %>% 
  dplyr::pull(Key)



excel_files_in_shiny <- paste("fastq/" , list.files(path="data/fastq"), sep="")



excel_to_get_from_s3 <- setdiff(excel_files_in_s3, excel_files_in_shiny )
excel_to_get_from_s3 <- excel_to_get_from_s3[ grep("xlsx", excel_to_get_from_s3)]


save_excel_files <- function(file) {
  
  # if object doesn't exist in bucket, return NA
  ok <- object_exists(
    object = file,
    bucket = "s3://seqwell-dashboard/", 
    prefix = "fastq",
    region = "us-east-1"
  )
  if(!ok) return(NA_character_)
  
  # if object exists, save it and return file path
  save_object(
    object = file,
    bucket = "s3://seqwell-dashboard/", 
    prefix = "fastq",
    region = "us-east-1",
    file = paste0("data/", file)
  )
}


excel_to_get_from_s3 %>% 
  purrr::map_chr(save_excel_files)