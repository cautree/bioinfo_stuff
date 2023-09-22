


stats_files_in_folder  <-  function(x){
  files = list.files(paste("data/services/", x, sep=""), pattern = "stats.txt")
  return(files)
  
}


plate_files_in_folder  <-  function(x){
  files = list.files(paste("data/services/", x, sep=""), pattern = "csv")
  return(files)
  
}


links_files_in_folder  <-  function(x){
  files = list.files(paste("data/services/", x, sep=""), pattern = "links.txt")
  return(files)
  
}


get_assemble_rep <- function(x){
  
  df = readr::read_csv(x)
  
  w_an_assembly <- df %>% 
    dplyr::filter( ! is.na(Length)) %>% 
    dplyr::summarise(n=n()) %>% 
    dplyr::pull(n)
  
  w_circular_assembly <- df %>% 
    dplyr::filter(Circle ==1) %>% 
    dplyr::summarise(n=n()) %>% 
    dplyr::pull(n)
  
  seq_count_coverage_filtered <- df %>% 
    dplyr::filter( `# Sequences` >100 & MEAN_coverage>40) %>% 
    dplyr::summarise(n=n()) %>% 
    dplyr::pull(n)
  
  rep = data.frame( w_an_assembly = w_an_assembly,
                    w_circular_assembly = w_circular_assembly,
                    Sequences_counts_100_MEAN_coverage_40 = seq_count_coverage_filtered, stringsAsFactors = F )
  
  return( rep)
  
}



get_size_all <- function( selected_runs){
  
  service_df = data.frame( run_name  = selected_runs$run_name, stringsAsFactors = F )
  
  file_paths <- service_df %>% 
    dplyr::mutate( files = purrr::map(run_name, stats_files_in_folder)) %>% 
    tidyr::unnest() %>% 
    dplyr::mutate( path =  paste("data/services", run_name, files, sep="/" )) 
  
  
  service_stats <- file_paths %>% 
    dplyr::mutate( size_rep = purrr::map(path, function(x){
      y = readr::read_table(x, col_names = F) 
      
      y1 = y %>% 
        dplyr::filter( X1 %in% c("Undetermined", "Total")) %>% 
        dplyr::mutate(X2 = stringr::str_replace_all(X2, "Gb", "")) %>% 
        dplyr::mutate(X2 = as.numeric(X2)) %>% 
        dplyr::rename( group = X1 ,
                       size = X2) 
      
      y2 = y %>%
        dplyr::filter(! X1 %in% c("Undetermined", "Total")) %>% 
        dplyr::mutate(X2 = stringr::str_replace_all(X2, "Gb", "")) %>% 
        dplyr::mutate(X2 = as.numeric(X2)) %>% 
        dplyr::summarise( size = sum(X2)) %>% 
        dplyr::mutate( run_name = run_name,
                       group = "Total - Undetermined")
      
      y_res = dplyr::bind_rows(y1, y2)
      
      return(y_res)
      
    })) %>% 
    tidyr::unnest() %>% 
    dplyr::mutate( sheet = stringr::str_replace_all(sheet, "_FASTQ", "")) %>% 
    dplyr::select(run_name, sheet, size) %>% 
    dplyr::mutate( key = paste(run_name, sheet, sep="_"))
  
  
  
  return(service_stats)
  
  
}




get_service_sum_size <- function( selected_runs){

  if( length(selected_runs) <1) {
    stop("make sure there are service data selected")
  } 
  
  service_df = data.frame( run_name  = selected_runs, stringsAsFactors = F )
  
  
  
  file_paths <- service_df %>% 
    dplyr::mutate( files = purrr::map(run_name, stats_files_in_folder)) %>% 
    tidyr::unnest() %>% 
    dplyr::mutate( path =  paste("data/services", run_name, files, sep="/" )) 
  
  
  service_stats <- file_paths %>% 
    dplyr::mutate( size_rep = purrr::map(path, function(x){
      y = readr::read_table(x, col_names = F) %>% 
        dplyr::filter(! X1 %in% c("Undetermined", "Total")) %>% 
        dplyr::rename( sheet = X1,
                       size = X2)
      return(y)
      
    })) %>% 
    tidyr::unnest() %>% 
    dplyr::mutate( sheet = stringr::str_replace_all(sheet, "_FASTQ", "")) %>% 
    dplyr::select(run_name, sheet, size) %>% 
    dplyr::mutate( key = paste(run_name, sheet, sep="_"))
  
  
  
  plate_df <- service_df %>% 
    dplyr::mutate( file_name = purrr::map(run_name, plate_files_in_folder)) %>% 
    tidyr::unnest() %>% 
    dplyr::mutate( sheet = stringr::str_replace_all(file_name, ".csv", "")) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate( key = paste(run_name, sheet, sep="_")) %>% 
    dplyr::mutate( path =  paste("data/services", run_name, file_name, sep="/" )) 
  
  common <- intersect( service_stats$key, plate_df$key)
  
  service_stats_s <- service_stats %>% 
    dplyr::filter( key %in% common ) %>% 
    dplyr::select(-key) 
  
  
  
  plate_df_s <- plate_df %>% 
    dplyr::filter( key %in% common ) %>% 
    dplyr::select(-key) 
  

  
  assemble_report <- plate_df_s %>% 
    dplyr::mutate( report = purrr::map(path, get_assemble_rep)) %>% 
    tidyr::unnest() 
  
  
  service_report_all <- service_stats_s %>%
    dplyr::left_join( assemble_report, by =c("run_name", "sheet"))  %>% 
    dplyr::select( -file_name, -path) %>% 
    dplyr::rename( plate = sheet,
                   yield = size,
                   number_assembled = w_an_assembly,
                   number_circular = w_circular_assembly,
                   `Sequences greater than 100(coverage greater than 40)` = Sequences_counts_100_MEAN_coverage_40)
  
  
  return(service_report_all)
  
}




get_service_link <- function( selected_runs){
  
  if( length(selected_runs) <1) {
    stop("make sure there are service data selected")
  }
  
  service_run_names = list.files("data/services/")

  service_df = data.frame( run_name  = selected_runs, stringsAsFactors = F )
  
  
  link_df <- service_df %>% 
    dplyr::filter( run_name %in% service_run_names) %>% 
    dplyr::mutate( file_name = purrr::map(run_name, links_files_in_folder)) %>% 
    dplyr::mutate( path =  paste("data/services", run_name, file_name, sep="/" ) ) %>% 
    dplyr::mutate( link = purrr::map(path, function(x){
      y = readr::read_table(x, col_names = F) 
      names(y) = "links"
      return(y)
      
    })) %>% 
    tidyr::unnest() %>% 
    dplyr::select( -file_name, -path) 
  
  
  
  return(link_df)
  
}









get_size_for_all_services <- function( all_service_run){
  
  service_df = data.frame( run_name  = all_service_run, stringsAsFactors = F )
  
  file_paths <- service_df %>% 
    dplyr::mutate( files = purrr::map(run_name, stats_files_in_folder)) %>% 
    tidyr::unnest() %>% 
    dplyr::mutate( path =  paste("data/services", run_name, files, sep="/" )) 
  
  
  service_stats <- file_paths %>% 
    dplyr::mutate( size_rep = purrr::map(path, function(x){
      y = readr::read_table(x, col_names = F) 
      
      y1 = y %>% 
        dplyr::filter( X1 %in% c("Undetermined", "Total")) %>% 
        dplyr::mutate(X2 = stringr::str_replace_all(X2, "Gb", "")) %>% 
        dplyr::mutate(X2 = as.numeric(X2)) %>% 
        dplyr::rename( group = X1 ,
                       size = X2) 
      
      y2 = y %>%
        dplyr::filter(! X1 %in% c("Undetermined", "Total")) %>% 
        dplyr::mutate(X2 = stringr::str_replace_all(X2, "Gb", "")) %>% 
        dplyr::mutate(X2 = as.numeric(X2)) %>% 
        dplyr::summarise( size = sum(X2),
                          n_plate = n()) %>% 
        dplyr::mutate( size =  round(size/n_plate,3)) %>% 
        dplyr::mutate( group = "avg_per_plate") %>% 
        dplyr::select( -n_plate)
        
        
      
      y_res = dplyr::bind_rows(y1, y2)
      
      return(y_res)
      
    })) %>% 
    tidyr::unnest() %>% 
    dplyr::select(run_name, group, size) %>% 
    dplyr::mutate( size = paste(size, "Gb", sep="")) %>% 
    tidyr::spread( group, size) %>% 
    dplyr::select( run_name, Total, Undetermined, avg_per_plate) %>% 
    dplyr::arrange( desc(run_name))
  
  return(service_stats)
  
  
}

