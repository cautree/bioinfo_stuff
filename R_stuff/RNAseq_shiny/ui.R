

ui = tagList(
  #shinythemes::themeSelector(),
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this

    "HEK RNAseq Data Quality and Analysis",
    tabPanel("RNAseq quality",

             
             sidebarPanel(
               
               helpText("click to download the count table"),
               downloadButton(outputId = "count_table",
                              label = "Download count table"),
               
               helpText("click to download the FPKM table"),
               downloadButton(outputId = "FPKM_table",
                              label = "Download FPKM table")
             ),
             
             
             mainPanel(
               
               tabsetPanel(tabPanel("Experimental Samples",
                                    DT::dataTableOutput("exp_sample")),
                           tabPanel("PCA for all samples",
                                    plotOutput('plot1')),
                           tabPanel("hierarchical clustering for all samples",
                                    plotOutput('plot2')),
                           tabPanel("DE summary",DT::dataTableOutput("de_summary")),
                           tabPanel("Raw Counts",DT::dataTableOutput("raw_counts")),
                           tabPanel("FPKM",DT::dataTableOutput("FPKM"))
                           
                           
               )
               
             )
    ),
    
    tabPanel("Comparison of Interest",
             sidebarPanel(
               
               helpText("Please select the comparison below"),
               
              #Select variables to display ----
              selectInput("checkbox", "Comparisons",

                          c( "HEK_D04_vs_IL12_D04",  
                             "HEK_D04_vs_PrX_D04", 
                             "IL12_D04_vs_PrX_D04" ,
                             "IL12_perfusion_D07_vs_IL12_D04" ,   
                             "IL12_perfusion_D13_vs_IL12_D04" ,   
                             "PrX_perfusion_D06_vs_PrX_D04",   
                             "PrX_perfusion_D24_vs_PrX_D04",
                             "IL12_perfusion_vs_PrX_perfusion",
                             "PrX_perfusion_D06_vs_Exosome",
                             "PrX_perfusion_D24_vs_Exosome"),
                          
                          selected = 1

              ),
            
            
            selectizeInput(
              inputId = 'select_genes', label = 'Select Genes',
              choices = NULL,
              selected = 1,
              multiple = TRUE
            ),
            
            
            
            helpText("Tables for DE genes"),
            downloadButton(outputId = "de_sig",
                           label = "DEseq analysis"),
            downloadButton(outputId = "counts_sig",
                           label = "Normalized counts"),
            
            
            helpText("Tables for all genes"),
            downloadButton(outputId = "de_table",
                           label = "DEseq analysis"),
            downloadButton(outputId = "counts_all",
                           label = "Normalized counts"),
            
            
            helpText("Tables for selected genes"),
            downloadButton(outputId = "de_selected",
                           label = "DEseq analysis"),
            downloadButton(outputId = "norm_selected",
                           label = "Normalized counts")
    ),
            
             
             
             mainPanel(
               tabsetPanel(
                 
                 tabPanel("Noralmized_counts_plots", plotOutput("plot3")),
                 tabPanel("Heatmap_plot", plotOutput("plot4")),
                 tabPanel("Boxplot", plotOutput("plot5")),
                 tabPanel("DE gene Table",DT::dataTableOutput("detable")),
                 tabPanel("selected genes Table",DT::dataTableOutput("genetable")),
                 tabPanel("Boxplot for selected genes", plotOutput("plot6"))
               )
             )
    )
   
  )
)