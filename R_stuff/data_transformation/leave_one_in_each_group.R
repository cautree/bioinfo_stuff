df = readr::read_csv("results/bota_plasmids.csv")

## group by filename, select the one with the longest length
## the file name is like 72_AP-17026, stringr::str_extract_all is to get AP-17026
df = df %>% 
  tidyr::nest( -filename ) %>% 
  dplyr::mutate( data2 = purrr::map(.$data, function(x){
    x = x %>% 
      dplyr::arrange( -length )
    x = x[1,]
    return(x)
  })) %>% 
  dplyr::select( filename, data2 ) %>% 
  tidyr::unnest() %>% 
  dplyr::mutate( ref = stringr::str_extract_all(filename, "AP-[0-9]{2,}$", simplify = T)) %>%  
  dplyr::select( filename, ref, everything() ) %>% 
  dplyr::arrange( ref)