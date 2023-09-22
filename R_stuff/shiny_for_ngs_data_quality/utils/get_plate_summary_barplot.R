


get_plate_mean_pct_Perfectbarcode_barplot <- function(summary_res){
  p <- summary_res %>% 
    ggplot(aes(run_plate_name, mean_pct_perfect_plate)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}



get_plate_mean_pct_One_mismatchbarcode_barplot <- function(summary_res){
  p <- summary_res %>% 
    ggplot(aes(run_plate_name, mean_pct_One_mismatchbarcode_plate)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}




get_plate_mean_pct_Q30bases_plate_barplot <- function(summary_res){
  p <- summary_res %>% 
    ggplot(aes(run_plate_name, mean_pct_Q30bases_plate)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}



get_plate_cv_pct_plate_barplot <- function(summary_res){
  p <- summary_res %>% 
    ggplot(aes(run_plate_name, cv_pct_of_the_plate)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}

