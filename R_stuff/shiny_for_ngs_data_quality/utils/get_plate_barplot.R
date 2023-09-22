print("=====================================inside get plate barplot")
#plate 



get_pct_Perfectbarcode_barplot_plate <- function(df_selected_plate){
  p <- df_selected_plate %>% 
    ggplot(aes(Sample, `% Perfectbarcode`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}



get_pct_One_mismatchbarcode_barplot_plate <- function(df_selected_plate){
  p <- df_selected_plate %>% 
    ggplot(aes(Sample, `% One mismatchbarcode`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}




get_pct_Q30bases_barplot_plate <- function(df_selected_plate){
  p <- df_selected_plate %>% 
    ggplot(aes(Sample, `% >= Q30bases`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}



get_pct_plate_barplot_plate <- function(df_selected_plate){
  p <- df_selected_plate %>% 
    ggplot(aes(Sample, `% of the plate`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}

