# "PCT_PF_READS_ALIGNED"       
# [3] "PCT_PF_READS_IMPROPER_PAIRS" "PCT_CHIMERAS"               
# [5] "MEAN_INSERT_SIZE"            "MEDIAN_ABSOLUTE_DEVIATION"  
# [7] "MIN_INSERT_SIZE"             "MAX_INSERT_SIZE"            
# [9] "PERCENT_DUPLICATION"         "AT_DROPOUT"                 
# [11] "GC_DROPOUT"  


get_wgs_plot <- function( wgs_summary, var){
  
  wgs_summary <- wgs_summary[c("run_name", var)]
  
  print("===========================================in wgs barplot")

  p <- wgs_summary %>% 
    ggplot(aes(run_name, .data[[var]])) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
}