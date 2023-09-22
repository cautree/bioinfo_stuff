library(dplyr)



read_balancing_sheet <- function(x,y){
  
  csv = readxl::read_excel(x, sheet=y)
  return(csv)
}




get_fraction_of_plate_stats <- function( x){
  
  
  
  fraction_of_plate = x$`% of the plate`
  
  median_fr_plate = median( fraction_of_plate, na.rm = T)
  mean_fr_plate = mean( fraction_of_plate, na.rm = T)
  sd_fr_plate = sd( fraction_of_plate, na.rm = T)
  cv_fr_plate = sd_fr_plate/ mean_fr_plate
  
  min_fr_plate = min( fraction_of_plate, na.rm = T)
  max_fr_plate = max( fraction_of_plate, na.rm = T)
  
  max_min_ratio = max_fr_plate/ min_fr_plate
  
  around_50_pct_mean_low = mean_fr_plate - 0.5*mean_fr_plate
  around_33_pct_mean_low = mean_fr_plate - 0.33*mean_fr_plate
  around_25_pct_mean_low = mean_fr_plate - 0.25*mean_fr_plate
  
  
  around_50_pct_mean_high = mean_fr_plate + 0.5*mean_fr_plate
  around_33_pct_mean_high = mean_fr_plate + 0.33*mean_fr_plate
  around_25_pct_mean_high = mean_fr_plate + 0.25*mean_fr_plate
  
  n_low_50 = sum(fraction_of_plate < around_50_pct_mean_low)
  n_high_50 = sum(fraction_of_plate > around_50_pct_mean_high)
  
  
  n_low_33 = sum(fraction_of_plate < around_33_pct_mean_low)
  n_high_33 = sum(fraction_of_plate > around_33_pct_mean_high)
  
  
  n_low_25 = sum(fraction_of_plate < around_25_pct_mean_low)
  n_high_25 = sum(fraction_of_plate > around_25_pct_mean_high)
  
  df1 = data.frame( median_fr_plate = median_fr_plate, 
                    mean_fr_plate = mean_fr_plate,
                    sd_fr_plate = sd_fr_plate,
                    cv_fr_plate = cv_fr_plate,
                    min_fr_plate = min_fr_plate,
                    max_fr_plate = max_fr_plate,
                    max_min_ratio = max_min_ratio,
                    stringsAsFactors = F
                    )
  
  df1 = as.data.frame(t(df1))
  df1 = df1 %>% 
    dplyr::add_rownames( var = "stats") %>% 
    dplyr::mutate( V1 = round(V1, 4))
  names(df1)[2] = "value"
  return( df1)
}



get_fraction_of_plate_counts <- function( x){
  
  fraction_of_plate = x$`% of the plate`
  
  median_fr_plate = median( fraction_of_plate, na.rm = T)
  mean_fr_plate = mean( fraction_of_plate, na.rm = T)
  sd_fr_plate = sd( fraction_of_plate, na.rm = T)
  cv_fr_plate = sd_fr_plate/ mean_fr_plate
  
  min_fr_plate = min( fraction_of_plate, na.rm = T)
  max_fr_plate = max( fraction_of_plate, na.rm = T)
  
  max_min_ratio = max_fr_plate/ min_fr_plate
  
  around_50_pct_mean_low = mean_fr_plate - 0.5*mean_fr_plate
  around_33_pct_mean_low = mean_fr_plate - 0.33*mean_fr_plate
  around_25_pct_mean_low = mean_fr_plate - 0.25*mean_fr_plate
  
  around_50_pct_mean_high = mean_fr_plate + 0.5*mean_fr_plate
  around_33_pct_mean_high = mean_fr_plate + 0.33*mean_fr_plate
  around_25_pct_mean_high = mean_fr_plate + 0.25*mean_fr_plate
  
  n_low_50 = sum(fraction_of_plate < around_50_pct_mean_low)
  n_high_50 = sum(fraction_of_plate > around_50_pct_mean_high)
  
  
  n_low_33 = sum(fraction_of_plate < around_33_pct_mean_low)
  n_high_33 = sum(fraction_of_plate > around_33_pct_mean_high)
  
  
  n_low_25 = sum(fraction_of_plate < around_25_pct_mean_low)
  n_high_25 = sum(fraction_of_plate > around_25_pct_mean_high)
  
  
  df2 = data.frame( group = c("mean_50%_high", "mean_50%_low", "mean_33%_high", "mean_33%_low", "mean_25%_high", "mean_25%_low"),
                    value = c(around_50_pct_mean_high, around_50_pct_mean_low, around_33_pct_mean_high, 
                              around_33_pct_mean_low,around_25_pct_mean_high, around_25_pct_mean_low ),
                    count = c(n_high_50, n_low_50, n_high_33, n_low_33, n_high_25, n_low_25),
                    stringsAsFactors = F
  )
  
  return( df2)
}





get_fraction_of_plate_labelled <- function( x){
  
  fraction_of_plate = x$`% of the plate`
  
  median_fr_plate = median( fraction_of_plate, na.rm = T)
  mean_fr_plate = mean( fraction_of_plate, na.rm = T)
  sd_fr_plate = sd( fraction_of_plate, na.rm = T)
  cv_fr_plate = sd_fr_plate/ mean_fr_plate
  
  min_fr_plate = min( fraction_of_plate, na.rm = T)
  max_fr_plate = max( fraction_of_plate, na.rm = T)
  
  max_min_ratio = max_fr_plate/ min_fr_plate
  
  around_50_pct_mean_low = mean_fr_plate - 0.5*mean_fr_plate
  around_33_pct_mean_low = mean_fr_plate - 0.33*mean_fr_plate
  around_25_pct_mean_low = mean_fr_plate - 0.25*mean_fr_plate
  
  around_50_pct_mean_high = mean_fr_plate + 0.5*mean_fr_plate
  around_33_pct_mean_high = mean_fr_plate + 0.33*mean_fr_plate
  around_25_pct_mean_high = mean_fr_plate + 0.25*mean_fr_plate
  
  n_low_50 = sum(fraction_of_plate < around_50_pct_mean_low)
  n_high_50 = sum(fraction_of_plate > around_50_pct_mean_high)
  
  
  n_low_33 = sum(fraction_of_plate < around_33_pct_mean_low)
  n_high_33 = sum(fraction_of_plate > around_33_pct_mean_high)
  
  
  n_low_25 = sum(fraction_of_plate < around_25_pct_mean_low)
  n_high_25 = sum(fraction_of_plate > around_25_pct_mean_high)
  
  
  fraction_of_plate_s <- x %>% 
    dplyr::mutate( label = case_when(
      `% of the plate` < around_50_pct_mean_low ~ 1,
      `% of the plate` >= around_50_pct_mean_low & `% of the plate` < around_33_pct_mean_low ~ 2,
      `% of the plate` >= around_33_pct_mean_low & `% of the plate` < around_25_pct_mean_low ~ 3,
      `% of the plate` >= around_25_pct_mean_low & `% of the plate` < around_25_pct_mean_high ~ 4,
      `% of the plate` >= around_25_pct_mean_high & `% of the plate` < around_33_pct_mean_high ~ 5,
      `% of the plate` >= around_33_pct_mean_high & `% of the plate` < around_50_pct_mean_high ~ 6,
      `% of the plate` >= around_50_pct_mean_high  ~ 7, 
      TRUE ~ 0
      
      
    )) %>% 
    dplyr::mutate( color = case_when(
  
        
      label == 1 ~ "#FF0000",
      label == 2 ~ "#FF6347",
      label == 3 ~ "#FA8072",
      label == 4 ~ "#BEBEBE",
      label == 5 ~ "#87CEFA",
      label == 6 ~ "#1E90FF",
      label == 7 ~ "#0000FF"
      
      
      
      
    )) 
  
  
  return(fraction_of_plate_s)
  
  
}




color_df <- data.frame( order = c(1,2,3,4,5,6,7),
                       # color = c("red","tomato","salmon","grey","Light Sky Blue","Dodger Blue", "blue"),
                      
                        color = c("#FF0000", "#FF6347", "#FA8072", "#BEBEBE" ,"#87CEFA", "#1E90FF", "#0000FF"),
                        my_labels = c('below 50_pct_mean_low', 'above 50_pct_mean_low & below 33_pct_mean_low', 
                                   'above 33_pct_mean_low & below 25_pct_mean_low',"above 25_pct_mean_low & below 25_pct_mean_high", 
                                   "above 25_pct_mean_high & below 33_pct_mean_high","above 33_pct_mean_high & below 50_pct_mean_high","above 50_pct_mean_high"),
                        stringsAsFactors = F)




get_bar_plot_fraction_of_plate = function(x){
  
  fraction_of_plate_s = get_fraction_of_plate_labelled(x)
  
  fraction_of_plate_s = fraction_of_plate_s %>% 
    dplyr::select( well, `% of the plate`, label, color ) %>% 
    dplyr::mutate( label =as.factor( label))
  
  color = data.frame(color =  unique(fraction_of_plate_s$color), stringsAsFactors = F)
  
  color_frame = color %>% 
    dplyr::left_join( color_df, by = "color") %>% 
    dplyr::arrange( order)
  
  #my_color = factor(color_frame$color, levels=color_frame$color ) ## this is wrong
  my_color = color_frame$color
  my_label = color_frame$my_labels
  print(my_label)
    
  p = fraction_of_plate_s %>% 
    ggplot( aes(well, `% of the plate`, fill = label)) +
    geom_bar( stat= "identity") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    scale_fill_manual(
                         values=my_color, 
    labels= my_label)
  
  return(p)
  
}




get_bar_plot_fraction_row = function(x){
  
  fraction_of_plate_s = x %>% 
    dplyr::select( well, `% of the plate`) %>% 
    tidyr::separate( well, c("row", "column"), sep=1, remove = F ) %>% 
    dplyr::group_by(row) %>% 
    dplyr::summarise( `% of the plate` = sum(`% of the plate`))
  

  
  p = fraction_of_plate_s %>% 
    ggplot( aes(row, `% of the plate`)) +
    geom_bar( stat= "identity") 
  
  return(p)
  
}



get_bar_plot_fraction_column = function(x){
  
  fraction_of_plate_s = x %>% 
    dplyr::select( well, `% of the plate`) %>% 
    tidyr::separate( well, c("row", "column"), sep=1, remove = F ) %>% 
    dplyr::group_by(column) %>% 
    dplyr::summarise( `% of the plate` = sum(`% of the plate`))
  
  
  
  p = fraction_of_plate_s %>% 
    ggplot( aes(column, `% of the plate`)) +
    geom_bar( stat= "identity") 
  
  return(p)
  
}



