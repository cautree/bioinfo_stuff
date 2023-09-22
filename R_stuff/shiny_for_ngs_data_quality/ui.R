library(shinythemes)
library(shiny)
library(shinymanager)
library(ggpubr)






service_name = rev(service_info$run_name)

## for temp, should change to balancing_info
#balancing_run_name = unique(sample_info$run_name)
balancing_run_name = paste(balancing_info$run_name, balancing_info$sheet, sep=":")
balancing_calculation_run_name = unique( balancing_calculation_info$run_name)
crosstalking_run_name = unique(crosstalking_info$run_name)

sequencers = c("MiSeq-Appa", 
               "MiSeq-Sharkboy",
               "MiSeq-Yoda",
               "NextSeq2000",
               "NextSeq550",
               "Other",
               "NA")

##for sequencer selection to see machine
all_sequencer_name = c("MiSeq-Appa", 
               "MiSeq-Sharkboy",
               "MiSeq-Yoda",
               "NextSeq2000")



projects = c("Custom_Project", 
             "Invitae_pW-LR",
             "OLi_HC",
             "OneStep PurePlex_(384)",
             "PurePlex_(96)",
             "scRapid",
             "Services",
             "NA")

today = as.character(Sys.Date())
earlier_date = as.character(as.Date(today)-30)



ui = tagList(
  
  tags$head(
    HTML(
      "
          <script>
          var socket_timeout_interval
          var n = 0
          $(document).on('shiny:connected', function(event) {
          socket_timeout_interval = setInterval(function(){
          Shiny.onInputChange('count', n++)
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          </script>
          "
    )
  ),
  textOutput("keepAlive"),
  
  navbarPage( theme = shinytheme("cosmo"),
  
    
    "seqWell NGS RUN QUALITY",
    
    
    # tabPanel("NGS run summary",
    #          
    #          
    #          sidebarPanel(
    #            
    #            helpText("Please select the date range of NGS runs "),
    #            dateRangeInput("daterange", "Date range:",
    #                           start = earlier_date,
    #                           end   = today),
    #            
    #       
    #            helpText("Please select sequencers"),
    #            selectizeInput("sequencer", 
    #                           label = "Sequencer:",
    #                           choices = c("MiSeq-Appa", 
    #                                       "MiSeq-Sharkboy",
    #                                       "MiSeq-Yoda",
    #                                       "NextSeq2000",
    #                                       "NextSeq550",
    #                                       "Other",
    #                                       "NA"),
    #                           multiple = TRUE,
    #                           selected = sequencers),
    #            
    #          
    #            helpText("Please select projects"),
    #            selectizeInput("project", 
    #                           label = "Project:",
    #                           choices = c("Custom_Project", 
    #                                       "Invitae_pW-LR",
    #                                       "OLi_HC",
    #                                       "OneStep PurePlex_(384)",
    #                                       "PurePlex_(96)",
    #                                       "scRapid",
    #                                       "Services",
    #                                       "NA"),
    #                           multiple = TRUE,
    #                           selected = projects),
    #            
    #            
    #            #Select variables to display ----
    #            helpText("Please DO click the button below if finished selecting the NGS data"),
    #            actionButton("select_done", 
    #                         label =icon("tree-deciduous", lib = "glyphicon")),
    #            
    #            
    #            helpText("click to download the summary table"),
    #            downloadButton(outputId = "sum_table_run",
    #                           label = "Download run summary table")
    #          ),
    #          
    #          mainPanel(
    #            
    #            tabsetPanel(tabPanel("Summary table of NGS run",
    #                                 DT::dataTableOutput("run_sum")),
    #                        tabPanel("barplot of run Perfectbarcode",
    #                                 plotOutput('plot1a')),
    #                        tabPanel("barplot of run One mismatchbarcode",
    #                                 plotOutput('plot1b')),
    #                        tabPanel("barplot of run >= Q30bases",
    #                                 plotOutput('plot1c')),
    #                        tabPanel("barplot of run pct PFClusters",
    #                                 plotOutput('plot1d'))
    #            )
    #            
    #          )
    # ),
    
    
    
    
    # tabPanel("NGS run by plate summary",
    #          
    #          
    #          sidebarPanel(
    #            
    #            
    #            helpText("click to download the summary table"),
    #            downloadButton(outputId = "plate_sum_table",
    #                           label = "Download summary table")
    #          ),
    #          
    #          mainPanel(
    #            
    #            tabsetPanel(tabPanel("Summary table of NGS plate",
    #                                 DT::dataTableOutput("plate_sum")),
    #                        tabPanel("barplot of plate mean pct of perfect scores",
    #                                 plotOutput('plot2a')),
    #                        tabPanel("barplot of plate mean pct of One mismatchbarcode",
    #                                 plotOutput('plot2b')),
    #                        tabPanel("barplot of plate mean pct of >= Q30bases",
    #                                 plotOutput('plot2c')),
    #                        tabPanel("barplot of cv of per plate",
    #                                 plotOutput('plot2d'))
    #            )
    #            
    #          )
    # ),
    

    
    # tabPanel("Explore NGS data by plate",
    #          sidebarPanel(
    #            
    #            
    #            
    #            selectizeInput(
    #              inputId = 'select_ngs', label = 'Select NGS data by run name',
    #              choices = NULL,
    #              selected = NULL,
    #              multiple = FALSE
    #            ),
    #            
    #            helpText("Download tables for selected NGS run"),
    #            
    #            downloadButton(outputId = "selected_ngs_plate",
    #                           label = "csv summary file for selected NGS plate")
    #          ),
    #          
    # 
    #          mainPanel(
    #            tabsetPanel(
    #              
    #              tabPanel("selected plate",DT::dataTableOutput("plateOutput")),
    #              
    #              tabPanel("barplot of pct Perfectbarcode",
    #                       plotOutput('plot3a')),
    #              tabPanel("barplot of pct One_mismatchbarcode",
    #                       plotOutput('plot3b')),
    #              tabPanel("barplot of pct >=Q30bases",
    #                       plotOutput('plot3c')),
    #              tabPanel("barplot of pct_plate",
    #                       plotOutput('plot3d')),
    #              
    #            )
    #          )
    # ),
    
    
    
    # tabPanel("wgs summary",
    #          sidebarPanel(
    #            
    #           
    #            helpText("Download tables for selected wgs summary"),
    #            
    #            downloadButton(outputId = "selected_wgs",
    #                           label = "csv summary file for selected wgs"),
    #            
    #            helpText("Please select wgs QC measurement"),
    #            selectizeInput("wgs_var", 
    #                           label = "wgs QC measurement:",
    #                           choices = c("PCT_PF_READS_ALIGNED" ,      
    #                                       "PCT_PF_READS_IMPROPER_PAIRS",
    #                                       "PCT_CHIMERAS" ,              
    #                                       "MEAN_INSERT_SIZE" ,
    #                                       "MEDIAN_ABSOLUTE_DEVIATION",  
    #                                       "MIN_INSERT_SIZE" ,
    #                                       "MAX_INSERT_SIZE" ,           
    #                                       "PERCENT_DUPLICATION" ,
    #                                       "AT_DROPOUT" ,                
    #                                       "GC_DROPOUT"      ),
    #                           multiple = FALSE,
    #                           selected = NULL),
    #            
    #          ),
    #          
    #          
    #          mainPanel(
    #            tabsetPanel(
    #              
    #              tabPanel("selected wgs",DT::dataTableOutput("wgs_sum")),
    #              
    #              tabPanel("barplot of mean wgs QC measurement",
    #                       plotOutput('plot4'))
    #              
    #            )
    #          )
    # ),
    
 
    
    ### for service   
    tabPanel("Service",
             sidebarPanel(
               
               
               
               helpText("Please select service"),
               selectizeInput("list_service", "service project name", choices = service_name, multiple = FALSE),
               
               
               helpText("Download tables for selected service summary"),
               
               downloadButton(outputId = "selected_service_summary",
                              label = "per plate summary"),
               
               
               helpText("Download tables for selected service link"),
               
               downloadButton(outputId = "selected_service_link",
                              label = "links"),

               
             ),
             
             
             mainPanel(
               tabsetPanel(
                 tabPanel("All Service Runs Summary",DT::dataTableOutput("all_service_size")),
                 tabPanel("Size in Selected Service",DT::dataTableOutput("service_summary_Output")),
                 tabPanel("Selected Service Link",DT::dataTableOutput("service_link")),
                 
               )
             )
    ),
    
    
    
    ### for machine   
    tabPanel("Sequencer Status",
             sidebarPanel(
               
               
               helpText("Download tables for selected sequencer summary"),
               
               downloadButton(outputId = "selected_sequencer",
                              label = "csv summary file for selected sequencer"),
               
               
               helpText("Please select sequencer"),
               selectizeInput("individual_sequencer", "sequencer name", choices = all_sequencer_name, multiple = TRUE),
               
               
               helpText("Please select date range"),
               dateRangeInput("daterange_sequencer", "Date range:",
                              start = earlier_date,
                              end   = today),
               
               
             ),
             
             
             mainPanel(
               tabsetPanel(
                 

                 tabPanel("Sequencer_QC_Plot",
                          plotOutput('plot5a')),
                 tabPanel("Sequencer_QC_Stats",DT::dataTableOutput("sequencer_summary_Output")),
                 tabPanel("MiSeq_Density_Plot",
                          plotOutput('plot5b')),
                 tabPanel("MiSeq_Density_pct_PFCluster_Cor_Plot",
                          plotOutput('plot5d')),
                 tabPanel("NextSeq_pct_occupied_Plot",
                          plotOutput('plot5e')),
                 tabPanel("NextSeq_pct_occupied_pct_PFCluster_Cor_Plot",
                          plotOutput('plot5f'))
                 
               )
             )
    ),
    
    
  
    ############# for balancing
    
    tabPanel("balancing",
             sidebarPanel(
               
               
               
               
               
               helpText("Please select balancing sheet"),
               selectizeInput("individual_balancing_run", "balacning run name", choices = balancing_run_name, multiple = F)
               
               
             ),
             
             
             mainPanel(
               tabsetPanel(
                 
                 
                 
                 tabPanel("selected balancing summary: stats",DT::dataTableOutput("balancing_summary_Output1")),
                 tabPanel("selected balancing summary: counts",DT::dataTableOutput("balancing_summary_Output2")),
                 
                 tabPanel("bar plot for fraction of plate",
                          plotOutput('plot6a')),
                 tabPanel("bar plots for fraction of rows",
                          plotOutput('plot6b')),
                 tabPanel("bar plots for fraction of columns",
                          plotOutput('plot6c')),
                 
               )
             )
    ),
    
    
    
    tabPanel("balancing calculation",
             sidebarPanel(
               
               
               helpText("Download tables for balancing calculation"),
               
               downloadButton(outputId = "selected_balacning_calculation",
                              label = "csv file for selected balancing calculation"),
               
               
               helpText("Please select balancing calculation run"),
               selectizeInput("individual_balancing_calculation_run", "balacning calculation run name", choices = balancing_calculation_run_name, multiple = F),
               
               helpText("Please fill in Current Volume in mL"),
               numericInput("Current_Volume_in_mL_a", "Current Volume in mL", 10, min = 1, max = 100),
             
               
               
               helpText("Please fill in Stock Concentration"),
               numericInput("stock_conc_a", "Stock Concentration", 200, min = 100, max = 1000),
              
               
               
               helpText("Please fill in SB Concentration in nM"),
               numericInput("SB_Conc_a", "SB Concentration", 8, min = 1, max = 100),
              
               
               
             ),
             
             
             mainPanel(
               tabsetPanel(
                 
                 tabPanel("selected balancing run calculation",DT::dataTableOutput("balancing_calculation_Output1"))
                 
               )
             )
    ),
    
    
    
    
    tabPanel("crosstalk",
             sidebarPanel(
               
               
               helpText("Download tables for crosstalk report"),
               
               downloadButton(outputId = "selected_crosstalk_report",
                              label = "csv file for selected crosstalk report"),
               
               
               helpText("Please select crosstalk run"),
               selectizeInput("individual_crosstalking_run", "crosstalk run name", choices = crosstalking_run_name, multiple = F),
               
             ),
             
             
             mainPanel(
               tabsetPanel(
                 
                 tabPanel("selected crosstalk summary",DT::dataTableOutput("crosstalking_Output1")),
                 tabPanel("boxplot & dot for i5 TR",
                          plotOutput('plot7a')),
                 tabPanel("heatmap for crosstalk",
                          plotOutput('plot7b')),
                 tabPanel("heatmap for crosstalk(log2)",
                          plotOutput('plot7c')),
                 
                 
               )
             )
    )  ,
    
    
    
    tabPanel("balance outliers",
             sidebarPanel(
               
               
               helpText("Please select run group"),
               selectizeInput("run_group", 
                              label = "Run group:",
                              choices = c(1,2,3,4,5,6),
                              multiple = FALSE,
                              selected = c(1,2,3,4,5,6)),
               
               
               helpText("Download tables for outliers for balancing runs"),
               
               downloadButton(outputId = "balance_outliers",
                              label = "tables for outliers for balancing runs")
             ),
             
             
             mainPanel(
               tabsetPanel(
                 
                 tabPanel("balancing run info",DT::dataTableOutput("bal_info")),
                 tabPanel("outliers for selected balancing runs",DT::dataTableOutput("bal_Output"))
                 
                 
               )
             )
    )
    
    
    
    
  )
)

ui <- secure_app(ui)