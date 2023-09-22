
run_info <- run_info %>% 
  dplyr::left_join( meta_info, by = c( "run_name" )  ) %>% 
  dplyr::mutate( project_name = ifelse(is.na(project_name), "NA",project_name )) %>% 
  dplyr::mutate( Sequencer = ifelse(is.na(Sequencer), "NA",Sequencer )) 



sample_info <- sample_info %>% 
  dplyr::left_join( meta_info, by = c( "run_name" )  ) %>% 
  dplyr::mutate( project_name = ifelse(is.na(project_name), "NA",project_name )) %>% 
  dplyr::mutate( Sequencer = ifelse(is.na(Sequencer), "NA",Sequencer )) 

wgs_info <- wgs_info %>% 
  dplyr::left_join( meta_info, by = c( "run_name" )  ) %>% 
  dplyr::mutate( project_name = ifelse(is.na(project_name), "NA",project_name )) %>% 
  dplyr::mutate( Sequencer = ifelse(is.na(Sequencer), "NA",Sequencer ))




server = function(input, output, session) {
  
  
  output$keepAlive <- renderText({
    req(input$count)
    paste("keep alive ", input$count)
  })
  
  filtered_sample_info <- reactive({
    req(input$daterange)
    start = lubridate::date(input$daterange[1])
    end = lubridate::date(input$daterange[2] )

    
    project_names = input$project
    sequencer_names = input$sequencer
    

    sheet_info_by_date <- sample_info %>%
      dplyr::filter( date >= start &
                       date <= end ) %>% 
      dplyr::filter( project_name %in% project_names, 
                     Sequencer %in% sequencer_names)

    run_info_by_date <- run_info %>%
      dplyr::filter( date >= start &
                       date <= end ) %>% 
      dplyr::filter( project_name %in% project_names ,
                     Sequencer %in% sequencer_names)
    
    wgs_info_by_date <- wgs_info %>%
      dplyr::filter( date >= start &
                       date <= end ) %>% 
      dplyr::filter( project_name %in% project_names ,
                     Sequencer %in% sequencer_names)

    res <- list( sheet_info_by_date, run_info_by_date, wgs_info_by_date)


  })
  
  
 
  
  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  
  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })
  
  
  

  observeEvent(input$select_done, {
    
    updateSelectizeInput(session, "select_ngs",
                         choices = filtered_sample_info()[[1]]$run_pb,
                         server = TRUE)
  })
  
  
  
  selected_run_pb <- reactive({
    req(input$select_ngs)
    selected_ngs <- input$select_ngs
    print(selected_ngs)
    path= filtered_sample_info()[[1]] %>% 
      dplyr::filter( run_pb ==selected_ngs) %>%
      dplyr::pull( path)
    sheet= filtered_sample_info()[[1]] %>% 
      dplyr::filter( run_pb ==selected_ngs) %>%
      dplyr::pull( sheets)
    
    if(isSingleString(path)){
      df <- readxl::read_excel( path, sheet = sheet)
    } else{
      
      stop("please make sure click the done selection button")
    }
    
    
    
  })
  
  sheet_summary_results <- reactive({
    req(filtered_sample_info())
    sheet_selected <- filtered_sample_info()[[1]]
    
    summary_res <- get_sheet_summary_reports(sheet_selected)
    
  }
)
  
  
  run_summary_results <- reactive({
    req(filtered_sample_info())
    run_selected <- filtered_sample_info()[[2]]
    
    summary_res <- get_run_summary_reports(run_selected)
    
  }
  )
  
  
  
  wgs_summary_results <- reactive({
    req(filtered_sample_info())
    wgs_selected <- filtered_sample_info()[[3]]
    path_list = wgs_selected$path
    run_name_list = wgs_selected$run_name
    summary_res <- purrr::map2_dfr(path_list, run_name_list,get_wgs_summary )
    
  }
  )
  
  
  
  output$plate_sum <-  DT::renderDataTable(
    
    sheet_summary_results()
  )
  
  output$run_sum <-  DT::renderDataTable(
    
    run_summary_results()
  )
  
  
  output$plateOutput <- DT::renderDataTable(
    selected_run_pb()
  )
  
  output$wgs_sum <-  DT::renderDataTable(
    
    wgs_summary_results()
  )
  
  
  
 ###for plate 
  output$plate_sum_table <- downloadHandler(
    filename = function() {
      "NGS plate summary table.csv"
    },
    content = function(file) {
      write.csv(sheet_summary_results(), file, row.names = FALSE)
    }
  ) 
  
  output$selected_ngs_plate <- downloadHandler(
    filename = function() {
      selected_ngs <- input$select_ngs
      paste( selected_ngs, ".csv")
    
    },
    content = function(file) {
      write.csv(selected_run_pb(), file, row.names = FALSE)
    }
  ) 
  
## for runs  
  output$sum_table_run <- downloadHandler(
    filename = function() {
      "NGS run summary table.csv"
    },
    content = function(file) {
      write.csv(run_summary_results(), file, row.names = FALSE)
    }
  ) 
  
 #for wgs 
  output$selected_wgs <- downloadHandler(
    filename = function() {
      "wgs summary table.csv"
    },
    content = function(file) {
      write.csv(wgs_summary_results(), file, row.names = FALSE)
    }
  ) 

  output$plot1a <- renderPlot({
    
    run_summary_res <- run_summary_results()
    req(run_summary_res)
    p <- get_Perfectbarcode_barplot_run(run_summary_res)
    print(p)
  }, height = 600, width = 900)  
  
  output$plot1b <- renderPlot({
    
    run_summary_res <- run_summary_results()
    req(run_summary_res)
    p <- get_One_mismatchbarcode_barplot_run(run_summary_res)
    print(p)
  }, height = 600, width = 900)  
  
  
  output$plot1c <- renderPlot({
    
    run_summary_res <- run_summary_results()
    req(run_summary_res)
    p <- get_Q30bases_barplot_run(run_summary_res)
    print(p)
  }, height = 600, width = 900)  
  
  
  output$plot1d <- renderPlot({
    
    run_summary_res <- run_summary_results()
    req(run_summary_res)
    p <- get_PFClusters_barplot_run(run_summary_res)
    print(p)
  }, height = 600, width = 900)  
  
  
  
  
 #####for plate 
  
  output$plot2a <- renderPlot({
    
    sheet_summary_res <- sheet_summary_results()
    req(sheet_summary_res)
    p <- get_plate_mean_pct_Perfectbarcode_barplot(sheet_summary_res)
    print(p)
  }, height = 600, width = 900)
  
  
  output$plot2b <- renderPlot({
    
    sheet_summary_res <- sheet_summary_results()
    req(sheet_summary_res)
    p <- get_plate_mean_pct_One_mismatchbarcode_barplot(sheet_summary_res)
    print(p)
  }, height = 600, width = 900)
  

  output$plot2c <- renderPlot({
    
    sheet_summary_res <- sheet_summary_results()
    req(sheet_summary_res)
    p <- get_plate_mean_pct_Q30bases_plate_barplot(sheet_summary_res)
    print(p)
  }, height = 600, width = 900)
  
  output$plot2d <- renderPlot({
    
    sheet_summary_res <- sheet_summary_results()
    req(sheet_summary_res)
    p <- get_plate_cv_pct_plate_barplot(sheet_summary_res)
    print(p)
  }, height = 600, width = 900)
  
  
  
####for explore plate  
  output$plot3a <- renderPlot({
    req(input$select_ngs)
    df_selected <- selected_run_pb()
    p <- get_pct_Perfectbarcode_barplot_plate(df_selected)
   
    print(p)
  }, height = 600, width = 900)
  
  
  output$plot3b <- renderPlot({
    req(input$select_ngs)
    df_selected <- selected_run_pb()
    p <- get_pct_One_mismatchbarcode_barplot_plate(df_selected)
    print(p)
  }, height = 600, width = 900)
  
  
  output$plot3c <- renderPlot({
    req(input$select_ngs)
    df_selected <- selected_run_pb()
    p <- get_pct_Q30bases_barplot_plate(df_selected)
    print(p)
  }, height = 600, width = 900)
  
  output$plot3d <- renderPlot({
    req(input$select_ngs)
    df_selected <- selected_run_pb()
    p <- get_pct_plate_barplot_plate(df_selected)
    print(p)
  }, height = 600, width = 900)
  
  
  ###### wgs plots
  
  output$plot4 <- renderPlot({
    req(input$wgs_var)
    var = input$wgs_var
    wgs_summary_selected <- wgs_summary_results()
    p <- get_wgs_plot(wgs_summary_selected, var)
    print(p)
  }, height = 600, width = 900)
  
  
  
  
 
  
  ##### service
  
  
  
  
  service_summary_results <- reactive({
    
    req( input$list_service)
    run_selected <- input$list_service
    summary_res <- get_service_sum_size(run_selected)
    
  }
  )
  
  service_link  <- reactive({
  
    req( input$list_service)
    run_selected <- input$list_service
    
    link <- get_service_link(run_selected)
    
  }
  )
  
  
  output$service_summary_Output <-  DT::renderDataTable(

    service_summary_results()
  )
  
  output$service_link <-  DT::renderDataTable(
    
    service_link()
  )
  
  
  
  output$selected_service_summary <- downloadHandler(
    filename = function() {
      "selected service summary table.csv"
    },
    content = function(file) {
      write.csv(service_summary_results(), file, row.names = FALSE)
    }
  ) 
  
  
  output$selected_service_link <- downloadHandler(
    filename = function() {
      "selected service link.csv"
    },
    content = function(file) {
      write.csv(service_link(), file, row.names = FALSE)
    }
  ) 
  
  
  
  
  get_all_service_size  <- reactive({
    
    size <- get_size_for_all_services(service_info$run_name)
    
  }
  )
  
  
  
  output$all_service_size <-  DT::renderDataTable(
    
    get_all_service_size()
  )
  
  
 #####################disply selected service 
  # selected_service_size <- reactive({
  #   req(input$select_ngs)
  #   selected_ngs <- input$select_ngs
  #   print(selected_ngs)
  #   run_name= filtered_sample_info()[[1]] %>% 
  #     dplyr::filter( run_pb ==selected_ngs) %>%
  #     dplyr::pull(run_name)
  #   
  #   service_size = get_service_sum_size(run_name)
  #   
  # })
  # 
  # output$service_summary_Output <-  DT::renderDataTable(
  #   
  #   selected_service_size()
  # )

  
  
  
###########################################################
  
  
  
  
  
  
  
  ##### sequencer
  sequencer_summary_results <- reactive({
    
    req( input$individual_sequencer)
    req( input$daterange_sequencer)
    
    sequencer = input$individual_sequencer
    start = lubridate::date(input$daterange_sequencer[1])
    end = lubridate::date(input$daterange_sequencer[2] )
    
    summary_res <- get_sequencer_reports_with_dates( sequencer, start, end)
    
  }
  )
  
  output$sequencer_summary_Output <-  DT::renderDataTable(
    
    sequencer_summary_results()
  )
  
  
  output$selected_sequencer <- downloadHandler(
    filename = function() {
      "NGS selected sequencer summary table.csv"
    },
    content = function(file) {
      write.csv(sequencer_summary_results(), file, row.names = FALSE)
    }
  ) 
  
  #get_plots_sequencer
  
  
  
  
  
  output$plot5a <- renderPlot({
    
    
    
    summary_res <- sequencer_summary_results()
    
    p <- get_line_plots_sequencer(summary_res)
    print(p)
  }, height = 600, width = 900)
  
  output$plot5b <- renderPlot({
    summary_res <- sequencer_summary_results()
    
    p <- get_density_percent_pf_cluster_line(summary_res)
    print(p)
  }, height = 600, width = 900)
  
  
  output$plot5c <- renderPlot({
    summary_res <- sequencer_summary_results()
    
    p <- get_bar_plots_sequencer(summary_res)
    print(p)
  }, height = 600, width = 900)
  
  
  output$plot5d <- renderPlot({
    summary_res <- sequencer_summary_results()
    
    p <- get_density_percent_pf_cluster_cor(summary_res)
    print(p)
  }, height = 600, width = 900)
  
  
  
  output$plot5e <- renderPlot({
    summary_res <- sequencer_summary_results()
    
    p <- get_occupied_percent_pf_cluster_line(summary_res)
    print(p)
  }, height = 600, width = 900)
  
  output$plot5f <- renderPlot({
    summary_res <- sequencer_summary_results()
    
    p <- get_occupied_percent_pf_cluster_cor(summary_res)
    print(p)
  }, height = 600, width = 900)
  
  #### balancing
  
  get_balancing_sheet <- reactive({
    
    req( input$individual_balancing_run)
    balancing_run = input$individual_balancing_run 
    
    x = unlist(strsplit(balancing_run, ":"))[[1]]
    y = unlist(strsplit(balancing_run, ":"))[[2]]
    x = paste("data/fastq/",x,".xlsx", sep="")
    
    data = read_balancing_sheet (x,y )
    
    
  })
  
  
  
  balancing_results_stats <- reactive({
    
    data = get_balancing_sheet()
    
    summary_res <- get_fraction_of_plate_stats( data)
    
  }
  )
  
  
  
  
  
  balancing_results_counts <- reactive({
    
    data = get_balancing_sheet()
    
    summary_res <- get_fraction_of_plate_counts( data)
    
  }
  )
  
  
  output$balancing_summary_Output1 <-  DT::renderDataTable(
    
  
    balancing_results_stats()
  )
  
  output$balancing_summary_Output2 <-  DT::renderDataTable(
    
    balancing_results_counts()
  )
  
  
  output$plot6a <- renderPlot({
    
    data = get_balancing_sheet()
    
    p <- get_bar_plot_fraction_of_plate(data)
    print(p)
  }, height = 600, width = 900)
  
  
  
  output$plot6b <- renderPlot({
    
    data = get_balancing_sheet()
    
    p <- get_bar_plot_fraction_row(data)
    print(p)
  }, height = 600, width = 900)
  
  
  output$plot6c <- renderPlot({
    
    data = get_balancing_sheet()
    
    p <- get_bar_plot_fraction_column(data)
    print(p)
  }, height = 600, width = 900)
  
  
  
  
  # #### balancing calculation
  
  
  balancing_calculation_results <- reactive({
    
    req( input$individual_balancing_calculation_run)
    req( input$Current_Volume_in_mL_a)
    req( input$stock_conc_a)
    req( input$SB_Conc_a)
    
    
    balancing_run = input$individual_balancing_calculation_run 
    Current_Volume_in_mL_b = input$Current_Volume_in_mL_a
    stock_conc_b = input$stock_conc_a
    SB_Conc_b = input$SB_Conc_a
    
    get_balancing_calculation(balancing_run,  Current_Volume_mL_ = Current_Volume_in_mL_b, 
                                              Stock_Conc_ = stock_conc_b, 
                                              SB_Conc_nM_ = SB_Conc_b)
    
  })
  
  
  output$balancing_calculation_Output1 <-  DT::renderDataTable(
    
    
    balancing_calculation_results()[[1]]
  )
  
  
  
  output$selected_balacning_calculation <- downloadHandler(
    filename = function() {
      "selected_balacning_calculation.csv"
    },
    content = function(file) {
      write.csv(balancing_calculation_results(), file, row.names = FALSE)
    }
  ) 
  
  
  
  
  
  ######cross talking
  
  get_cross_talking_results <- reactive({
    
    req( input$individual_crosstalking_run)
   
    
    
    crosstalking_run = input$individual_crosstalking_run 
    
    
    get_crosstalk_summary(crosstalking_run)
    
  })
  
  output$crosstalking_Output1 <-  DT::renderDataTable(
    get_cross_talking_results()
  )
  
  output$plot7a <-  renderPlot({
    
    req( input$individual_crosstalking_run)
    crosstalking_run = input$individual_crosstalking_run 
    
    p <- get_crosstalk_i5_boxplot(crosstalking_run)
    print(p)
  }, height = 800, width = 1100)
  
  
  output$plot7b <-  renderPlot({
    
    req( input$individual_crosstalking_run)
    crosstalking_run = input$individual_crosstalking_run 
    
    df = get_crosstalk_data(crosstalking_run)
    
    nr = nrow(df)
    if( nr ==24) {
      hw = 20
    } else{
      hw = 6
    }
    
    heat_colors <- brewer.pal(4, "YlOrRd")
    pheatmap(df, cluster_cols = FALSE, 
             cluster_rows = FALSE, color=heat_colors, 
             fontsize_row = 7, fontsize_col = 7,
             cellwidth = hw, cellheight = hw)
  }, height = 800, width = 1100)
  
  
  
  output$plot7c <-  renderPlot({
    
    req( input$individual_crosstalking_run)
    crosstalking_run = input$individual_crosstalking_run 
    
    df = get_crosstalk_data(crosstalking_run)
    
    nr = nrow(df)
    if( nr ==24) {
      hw = 20
    } else{
      hw = 6
    }
    
    df_log2 = log2(as.matrix(df+1))
    
    heat_colors <- brewer.pal(4, "YlOrRd")
    pheatmap(df_log2, cluster_cols = FALSE, 
                           cluster_rows = FALSE, color=heat_colors, 
                           fontsize_row = 7, fontsize_col = 7,
             cellwidth = hw, cellheight = hw)
  }, height = 800, width = 1100)
  
  
  
  
  output$selected_crosstalk_report <- downloadHandler(
    filename = function() {
      "selected_crosstalk_report.csv"
    },
    content = function(file) {
      write.csv(get_cross_talking_results(), file, row.names = FALSE)
    }
  ) 
  
  
  
  ## i5 and i7 balancine
  balance_results <- reactive({
    
    req(input$run_group)
    run_selected <- input$run_group
    
    
    if (run_selected %in% c(1,3,5)){
      summary_res <- get_i5_outlier(run_selected)
    } 
    
    else if (run_selected %in% c(2,4,6)){
      summary_res <- get_i7_outlier(run_selected)
    } 
    
    
    
  }
  )
  
  output$bal_Output <-  DT::renderDataTable(
    
    balance_results()
  )
  
  get_small_balance = reactive({
    small_balance_info = balance_info[ c("Kit","Set", "Reagent", "Round", "Sequencing", "group")] %>% 
      dplyr::distinct()
    
  })
  output$bal_info <-  DT::renderDataTable(
    get_small_balance()
  
  )
  
  
  
  
  
  output$balance_outliers <- downloadHandler(
    filename = function() {
      "outlier_report.csv"
    },
    content = function(file) {
      write.csv(balance_results(), file, row.names = FALSE)
    }
  ) 
  
}





