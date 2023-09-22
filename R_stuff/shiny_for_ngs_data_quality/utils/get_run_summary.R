library(dplyr)


read_sheet <- function(x,y){
  
  csv = readxl::read_excel(x, sheet=y)
  return(csv)
}


get_pct_Perfectbarcode <- function(x, y){
  
  z = x %>% 
    dplyr::select(Lane, `% Perfectbarcode`) %>% 
    dplyr::mutate( run_name = y)

  return(z)
}


get_pct_One_mismatchbarcode <- function(x, y){
  
  z = x %>% 
    dplyr::select( Lane, `% One mismatchbarcode`) %>% 
    dplyr::mutate( run_name = y)

  return(z)
}



get_pct_Q30bases <- function(x, y){
  
  z = x %>% 
    dplyr::select(Lane, `% >= Q30bases`)%>% 
    dplyr::mutate( run_name = y)

  return(z)
}



get_pct_PFClusters <- function(x, y){
  
  z = x %>% 
    dplyr::select(Lane, `% PFClusters`)%>% 
    dplyr::mutate( run_name = y)
  
  return(z)
}


get_run_summary_reports <- function(all_runs){
  
  print("=======================================in get_run_summary_reports")
  
  path <- all_runs$path
  sheet <- all_runs$sheets
  
  ngs <- purrr::map2( path, sheet, read_sheet )
  run_name_vec <- all_runs$run_name
  
  pct_Perfectbarcode <- purrr::map2_dfr( ngs, run_name_vec, get_pct_Perfectbarcode)
  pct_One_mismatchbarcode <-  purrr::map2_dfr( ngs,run_name_vec, get_pct_One_mismatchbarcode)
  pct_Q30bases <- purrr::map2_dfr( ngs, run_name_vec, get_pct_Q30bases)
  pct_PFClusters <- purrr::map2_dfr( ngs, run_name_vec, get_pct_PFClusters)
  
  
  if(nrow(pct_Perfectbarcode)<1) {
    report <- NULL
  } else{
    
    report <- pct_Perfectbarcode %>% 
      dplyr::left_join( pct_One_mismatchbarcode, by = c("run_name", "Lane")) %>% 
      dplyr::left_join( pct_Q30bases, by = c("run_name", "Lane")) %>% 
      dplyr::left_join( pct_PFClusters, by = c("run_name", "Lane")) %>% 
      dplyr::left_join( cluster_info, by = c("run_name")) %>% 
      dplyr::left_join( occupency_info, by = c("run_name")) %>% 
      dplyr::select( run_name, Lane, `% PFClusters`, `% >= Q30bases`, `% Perfectbarcode`, `% One mismatchbarcode`, density, percent_occupied)
    
  }
  
  
  
  return(report)
  
}

get_Perfectbarcode_barplot_run <- function( summary_res){
  p <- summary_res %>% 
    dplyr::mutate( run_name_lane = paste(run_name, Lane, sep="_")) %>% 
    ggplot(aes(run_name_lane, `% Perfectbarcode`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
  
  
}


get_One_mismatchbarcode_barplot_run <- function( summary_res){
  p <- summary_res %>% 
    dplyr::mutate( run_name_lane = paste(run_name, Lane, sep="_")) %>% 
    ggplot(aes(run_name_lane, `% One mismatchbarcode`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
  
  
}



get_Q30bases_barplot_run <- function( summary_res){
  p <- summary_res %>% 
    dplyr::mutate( run_name_lane = paste(run_name, Lane, sep="_")) %>% 
    ggplot(aes(run_name_lane, `% >= Q30bases`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
  
  
}



get_PFClusters_barplot_run <- function( summary_res){
  p <- summary_res %>% 
    dplyr::mutate( run_name_lane = paste(run_name, Lane, sep="_")) %>% 
    ggplot(aes(run_name_lane, `% PFClusters`)) +
    geom_bar(stat="identity") +
    theme(axis.text.x=element_text(angle=90, hjust=1))
  
  return(p)
  
  
}






##for machine

get_sequencer_reports <- function(all_runs){
  
  print("=======================================in get_run_summary_reports")
  
  path <- all_runs$path
  sheet <- all_runs$sheets
  
  all_runs_s <- all_runs %>% 
    dplyr::select( run_name, Sequencer, date)
  
  ngs <- purrr::map2( path, sheet, read_sheet )
  run_name_vec <- all_runs$run_name
  
  pct_PFClusters <- purrr::map2_dfr( ngs, run_name_vec, get_pct_PFClusters)
  pct_Q30bases <- purrr::map2_dfr( ngs, run_name_vec, get_pct_Q30bases)
  
  if(nrow(pct_PFClusters)<1) {
    report <- NULL
  } else{
    
    report <- pct_PFClusters %>% 
      dplyr::left_join( pct_Q30bases, by = c("run_name", "Lane")) %>% 
      dplyr::left_join( all_runs_s, by = "run_name") %>% 
      dplyr::select( run_name, Sequencer, date, Lane, `% PFClusters`, `% >= Q30bases`) %>% 
      tidyr::nest( -run_name) %>% 
      dplyr::mutate( data2 = purrr::map(.$data, function(x){
        if( nrow(x) >1){
          
          x =  apply(x, 2, mean, na.rm=T)
          
        }else{
          x= x
        }
        return(x)
        
      })) %>% 
      dplyr::select(-data) %>% 
      tidyr::unnest() %>% 
      dplyr::select(-Lane) %>% 
      dplyr::arrange( Sequencer)
    
  }
  
  
  
  return(report)
  
}


get_dot_plots_sequencer <- function(df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  
  
  if(n_sequencer >1) {
    p <- NULL
  } else{
    
    df_long <- df %>% 
      tidyr::gather( `% PFClusters`: `% >= Q30bases`,  key = "measure", value = "reading") %>% 
      dplyr::mutate( Quality= ifelse( reading<80, "bad", "good")) %>% 
      dplyr::mutate(measure = as.factor(measure) )
    
    p =  df_long %>% 
      ggplot( aes(date, reading, color = measure, shape = Quality )) + 
      geom_point( size = 5) + 
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100)
    
    
  }
  
  return(p)
  
}


get_line_plots_sequencer <- function(df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  df_long <- df %>% 
    tidyr::gather( `% PFClusters`: `% >= Q30bases`,  key = "measure", value = "reading") %>% 
    dplyr::mutate( Quality= ifelse( reading<80, "bad", "good")) %>% 
    dplyr::mutate(measure = as.factor(measure) ) 
  
  
  if(n_sequencer ==1) {
    
    
    p =  df_long %>% 
      ggplot() + 
      geom_point(aes(date, reading, color = measure )) +
      geom_line( aes(date, reading, color = measure )) + 
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100) +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"),
            legend.text=element_text(size=12),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      geom_hline(yintercept=85, linetype="dashed", color = "black")
    
  } else{
    
    n = n_sequencer
    p =  df_long %>% 
      ggplot() + 
      geom_point(aes(date, reading, color = measure )) +
      geom_line( aes(date, reading, color = measure )) + 
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100) +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"),
            legend.text=element_text(size=12),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      geom_hline(yintercept=85, linetype="dashed", color = "black") +
      facet_wrap(~ Sequencer, nrow = n)
    
    
    
  }
  
  return(p)
  
}





get_bar_plots_sequencer <- function(df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  df_long <- df %>% 
    tidyr::gather( `% PFClusters`: `% >= Q30bases`,  key = "measure", value = "reading") %>% 
    dplyr::mutate( Quality= ifelse( reading<80, "bad", "good")) %>% 
    dplyr::mutate(measure = as.factor(measure) )%>% 
    dplyr::mutate( date = as.character(date))
  
  if(n_sequencer ==1) {
    p =  df_long %>% 
      ggplot(aes(date, reading, fill = measure )) + 
      geom_bar( stat="identity",  position=position_dodge()) +
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100) +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"),
            legend.text=element_text(size=12),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      geom_hline(yintercept=85, linetype="dashed", color = "black")
    
  } else{
    
    n= n_sequencer
    p =  df_long %>% 
      ggplot(aes(date, reading, fill = measure )) + 
      geom_bar( stat="identity",  position=position_dodge()) +
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100) +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"),
            legend.text=element_text(size=12),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      geom_hline(yintercept=85, linetype="dashed", color = "black") +
      facet_wrap( ~ Sequencer, nrow = n)
    
    
    
    
    
  }
  
  return(p)
  
}







bar_plots_each_sequencer_30_most_recent_run <- function( sequencer_selected){
  
  df_sequencer = readr::read_csv("info/run_info.csv")
  
  df_sequencer_s <- df_sequencer %>% 
    dplyr::filter( Sequencer %in% sequencer_selected) %>% 
    dplyr::group_by( Sequencer) %>% 
    dplyr::top_n( date, n=30) 
  
  
  report0 = get_run_summary_reports(df_sequencer_s)
  
  report <- report0 %>% 
    dplyr::left_join( df_sequencer_s, by = "run_name")
  
  
  df_long <- report %>% 
    tidyr::gather( `% PFClusters`: `% >= Q30bases`,  key = "measure", value = "reading") %>% 
    dplyr::mutate( Quality= ifelse( reading<80, "bad", "good")) %>% 
    dplyr::mutate(measure = as.factor(measure) )
  
  length_seq = length(sequencer_selected )
  
  if( length_seq ==1){
    
    p =  df_long %>% 
      ggplot(aes(date, reading, color = measure )) + 
      geom_line() +
      geom_point() +
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100) +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"),
            legend.text=element_text(size=12),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      geom_hline(yintercept=85, linetype="dashed", color = "black")
    
    
  } else{
    n = length_seq
    p =  df_long %>% 
      ggplot(aes(date, reading, color = measure )) + 
      geom_line() +
      geom_point() +
      xlab('Dates') +
      ylab('measure reading') +
      ylim(0, 100) +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"),
            legend.text=element_text(size=12),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
      geom_hline(yintercept=85, linetype="dashed", color = "black") +
      facet_wrap( ~Sequencer , nrow = n)
    
  }
  
  return(p)
  
}







get_sequencer_reports_with_dates <- function( sequencer_selected, start, end){
  
  print("=======================================in get_run_summary_reports")
  
  run_info_30 <- run_info %>% 
    dplyr::filter( Sequencer %in% sequencer_selected) %>% 
    dplyr::group_by( Sequencer) %>% 
    dplyr::top_n( date, n=30) 
  
  
  selected_runs_s <- run_info %>% 
    dplyr::filter( Sequencer %in% sequencer_selected) %>% 
    dplyr::filter( date >= start & date <= end)
  
  path <- selected_runs_s$path
  sheet <- selected_runs_s$sheets
  
  ngs <- purrr::map2( path, sheet, read_sheet )
  run_name_vec <- selected_runs_s$run_name
  
  selected_runs_s <- selected_runs_s %>% 
    dplyr::select( run_name, Sequencer, date)
  
  pct_PFClusters <- purrr::map2_dfr( ngs, run_name_vec, get_pct_PFClusters)
  pct_Q30bases <- purrr::map2_dfr( ngs, run_name_vec, get_pct_Q30bases)
  
  ##########add in the cluster density and pct occupancy
  
  if(nrow(pct_PFClusters)<1) {
    report <- NULL
  } else{
    
    report <- pct_PFClusters %>% 
      dplyr::left_join( pct_Q30bases, by = c("run_name", "Lane")) %>% 
      dplyr::left_join( selected_runs_s, by = "run_name") %>% 
      dplyr::left_join( density_info, by = "run_name") %>% 
      dplyr::left_join( occupency_info, by = "run_name") %>% 
      dplyr::select( run_name, Sequencer, date, Lane, `% PFClusters`, `% >= Q30bases`, density, percent_occupied) %>% 
      tidyr::nest( -run_name) %>% 
      dplyr::mutate( data2 = purrr::map(.$data, function(x){
        if( nrow(x) >1){
          
          
          x =  apply(x, 2, mean, na.rm=T)
          x = as.data.frame(x)
          
        }else{
          x= x
        }
        return(x)
        
      })) %>% 
      dplyr::select(-data) %>% 
      tidyr::unnest() %>% 
      dplyr::select(-Lane) %>% 
      dplyr::arrange( Sequencer)
    
  }
  
  return(report)
  
}


get_density_percent_pf_cluster_line <- function( df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  if (sum(grepl("NextSeq", unique(df$Sequencer))) >0  ){
    p=NULL
    
  }
  

  
  len = length (df$density[! is.na(df$density)])
  if(len<2){
    p=NULL
  } else{
    
    
    
    df_long <- df %>% 
      dplyr::filter(!is.na(density)) %>% 
      dplyr::select(date, `% PFClusters`, density, Sequencer) %>% 
      tidyr::gather( `% PFClusters`: density,  key = "measure", value = "reading") %>% 
      dplyr::mutate(measure = as.factor(measure) )
    
    if( n_sequencer ==1){
      
      p =  df_long %>% 
        ggplot(aes(date, reading, color = measure )) + 
        geom_line() +
        geom_point() +
        xlab('Dates') +
        ylab('measure reading') +
        facet_wrap(~measure, scales="free_y", ncol =2) +
        theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14,face="bold"),
              legend.text=element_text(size=12),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
      
    } else{

      p =  df_long %>% 
        ggplot(aes(date, reading, color = measure )) + 
        geom_line() +
        geom_point() +
        xlab('Dates') +
        ylab('measure reading') +
        facet_grid( Sequencer ~ measure, scales="free_y", ncol=2) +
        theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14,face="bold"),
              legend.text=element_text(size=12),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
        geom_hline(yintercept=85, linetype="dashed", color = "black") 
    }
    
  }
  return(p)
  
}





get_density_percent_pf_cluster_cor <- function( df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  if (sum(grepl("NextSeq", unique(df$Sequencer))) >0  ){
    p=NULL
    
  }
  
  
  len = length (df$density[! is.na(df$density)])
  if(len<2){
    p=NULL
  } else{
    
    df <- df %>% 
      dplyr::filter(!is.na(density)) %>% 
      dplyr::select(date, `% PFClusters`, density, Sequencer) %>% 
      dplyr::mutate(Sequencer = as.factor(Sequencer) )
    
    
    
    if( n_sequencer ==1){
      
      p =  df %>% 
        ggplot(aes(`% PFClusters`, density )) + 
        geom_point() +
        geom_smooth(method=lm, se = FALSE)+
        stat_cor(method = "spearman", label.x = 90, label.y = 1500000)+
        xlab('% PFClusters') +
        ylab('cluster density') +
        xlim(70,100) +
        theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14,face="bold"),
              legend.text=element_text(size=12)) 
      
      
    } else{
      
      p =  df %>% 
        ggplot(aes(`% PFClusters`, density, color = Sequencer )) + 
        geom_point() +
        geom_smooth(method=lm, se = FALSE)+
        stat_cor(method = "spearman", label.x = 90, label.y = 1500000)+
        xlab('% PFClusters') +
        ylab('cluster density') +
        xlim(70,100) +
        facet_grid(~ Sequencer) +
        theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14,face="bold"),
              legend.text=element_text(size=12))  
      
    }
    
  }
  return(p)
  
}






get_occupied_percent_pf_cluster_line <- function( df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  if (sum(grepl("MiSeq", unique(df$Sequencer))) >0  ){
    p=NULL
    
  } else {
    
    len = length (df$percent_occupied[! is.na(df$percent_occupied)])
    
    if(len<2){
      p=NULL
    } else{
      
      
      
      df_long <- df %>% 
        dplyr::filter(!is.na(percent_occupied)) %>% 
        dplyr::select(date, `% PFClusters`, percent_occupied, Sequencer) %>% 
        tidyr::gather( `% PFClusters`: percent_occupied,  key = "measure", value = "reading") %>% 
        dplyr::mutate(measure = as.factor(measure) )
      

      
      p =  df_long %>% 
        ggplot(aes(date, reading, color = measure )) + 
        geom_line() +
        geom_point() +
        xlab('Dates') +
        ylab('measure reading') +
        facet_wrap(~measure, scales="free_y", ncol =2) +
        theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14,face="bold"),
              legend.text=element_text(size=12),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
    
  }
  
    
  }
  return(p)
  
}





get_occupied_percent_pf_cluster_cor <- function( df){
  
  n_sequencer = length(unique(df$Sequencer))
  
  if (sum(grepl("MiSeq", unique(df$Sequencer))) >0  ){
    p=NULL
    
  } else{
    
    len = length (df$percent_occupied[! is.na(df$percent_occupied)])
    if(len<2){
      p=NULL
    } else{
      
      df <- df %>% 
        dplyr::filter(!is.na(percent_occupied)) %>% 
        dplyr::select(date, `% PFClusters`, percent_occupied, Sequencer) 
      
      
      
      
      
      p =  df %>% 
        ggplot(aes(`% PFClusters`, percent_occupied )) + 
        geom_point() +
        geom_smooth(method=lm, se = FALSE)+
        stat_cor(method = "spearman", label.x = 70, label.y = 98)+
        xlab('% PFClusters') +
        ylab('percent_occupied') +
        xlim(70,90) +
        theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14,face="bold"),
              legend.text=element_text(size=12)) 
      
      
      
    
  }
    
  }
  return(p)
  
}











