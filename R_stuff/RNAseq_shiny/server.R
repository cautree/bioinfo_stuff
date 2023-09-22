library(ggplot2)
library(dplyr)
library(readr)
#library(raster)
#library(plotly)
#library(Rtsne)
library(grid)
library(gridExtra)
library(tidyr)
library(purrr)
library(broom)
library(data.table)
#library(tximport)
library(BiocManager)
library(DESeq2)
library(tidyverse)
library(RColorBrewer)
library(pheatmap)
library(ggrepel)
# library(rio)
# library(ashr)
library(ggpubr)


# BiocManager::repositories()
options(repos = BiocManager::repositories())
options('repos' = c(options('repos')$repos, RSPM = "https://git.bioconductor.org/packages/DESeq2"))


source("DE_plots.R")
source("get_data.R")




df_comparison <- readr::read_csv("data/compare.csv")


sample_info <- readr::read_csv("data/sample_info.csv")
rld <- read_rds("data/PID00012_22.rds")

counts <- data.table::fread("data/data_original/PID00012_22.Count.csv")
FPKM <- data.table::fread("data/data_original/PID00012_22.FPKM.csv")
counts <- as.data.frame(counts )
FPKM <- as.data.frame(FPKM)

head(counts)
head(FPKM)

names(counts) <- stringr::str_replace_all(names(counts), "\\-Depletion_001", "")
counts <- counts %>%
  dplyr::rename(GeneID = GeneName) %>% 
  select(GeneID, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)


names(FPKM) <- stringr::str_replace_all(names(FPKM), "\\-Depletion_001", "")
FPKM <- FPKM %>%
  dplyr::rename(GeneID = GeneName) %>% 
  select(GeneID, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12)




server = function(input, output, session) {
  
  ##PCA on all the samples
  output$plot1 <- renderPlot({
    p <- get_PCA_plots( rld, sample_info)
    p
  }, height = 600, width = 900)
  
  
  ##clustering on all the samples
  output$plot2 <- renderPlot({
    
    rld_mat <- assay(rld) 
    rld_cor <- cor(rld_mat)   
    meta <- sample_info %>% 
      dplyr::select(samplename) 
    rownames(meta) = meta$samplename
    
    my_sample_col <- data.frame(sample = sample_info$celltype)
    row.names(my_sample_col) <- colnames(rld_mat)
    col.pal <- RColorBrewer::brewer.pal(9, "Reds")
    
    pheatmap(rld_cor, annotation = meta, annotation_col = my_sample_col, color = col.pal)
    
  }, height = 600, width = 900)
  
  
  
  data <- reactive({
    selected_comp <- input$checkbox
    print(selected_comp)
    comp_res <- get_data( selected_comp)
  })

  
  
  observeEvent(input$checkbox, {
    selected_comp <- input$checkbox
    print(selected_comp)
    comp_res <- get_data( selected_comp)
    updateSelectizeInput(session, "select_genes",
                         choices = comp_res[[3]]$gene,
                         server = TRUE)
  })
  
  
  
  results_2 <- reactive({
    selected_genes <- input$select_genes
    print(selected_genes)

    df_norm <- data()[[4]]
    df <- get_the_boxplot_df( df_norm, selected_genes, sample_info)
    
  })
  
  
  
  results_3 <- reactive({
    
    selected_genes <- input$select_genes
    print(selected_genes)
    
    df_de <- data()[[3]]
    df <- df_de %>% 
      dplyr::filter(gene %in% selected_genes)
    
  })
  
  
  
  results <- reactive({
    
    selected_comp <- input$checkbox
    print(selected_comp)
    comp_res <- get_data( selected_comp)
    res <- get_results(comp_res[[1]], comp_res[[2]], sample_info)
    
  })
  
  
  output$plot3 <- renderPlot({
    res = results()
    p= res[[1]]
    print(p)
    
  })
  
  
  output$plot4 <- renderPlot({
    res = results()
    p= res[[2]]
    pheatmap(p)
  })
  
  output$plot5 <- renderPlot({
    res = results()
    p= res[[4]]
    print(p)
    
  }, height = 800, width = 600)
  
  
  output$detable <- DT::renderDataTable(
    results()[[3]]
  )
  
  output$genetable <- DT::renderDataTable(
    results_2()
  )
  
  
  table_de_sig <- reactive({
    table =data()[[1]]
  })
  
  table_counts_sig <- reactive({
    table =data()[[2]]
  })
  
  table_de_all <- reactive({
    table =data()[[3]]
  })
  
  table_norm_all <- reactive({
    table =data()[[4]]
  })
  
  # Downloadable csv of selected dataset ----
  output$de_sig <- downloadHandler(
    
    filename = function() {
      "DEseq_analysis_for_significant_genes.csv"
    },
    content = function(file) {
      write.csv(table_de_sig(), file, row.names = FALSE)
    }
  ) 
  
  output$counts_sig <- downloadHandler(
    
    filename = function() {
      "normalized_counts_for_significant_genes.csv"
    },
    content = function(file) {
      write.csv(table_counts_sig(), file, row.names = FALSE)
    }
  ) 
  
  
  # Downloadable csv of selected dataset ----
  output$de_table <- downloadHandler(
    
    filename = function() {
      "fold_change_table_for_all_genes.csv"
    },
    content = function(file) {
      write.csv(table_de_all(), file, row.names = FALSE)
    }
  ) 
  
  
  output$counts_all <- downloadHandler(
    
    filename = function() {
      "normalized_counts_for_all_genes.csv"
    },
    content = function(file) {
      write.csv(table_norm_all(), file, row.names = FALSE)
    }
  ) 
  
  
  
  
  output$norm_selected <- downloadHandler(
    filename = function() {
      "normalized_counts_for_selected_genes.csv"
    },
    content = function(file) {
      write.csv(results_2(), file, row.names = FALSE)
    }
  ) 
 
  ##working on now 
  output$de_selected <- downloadHandler(
    filename = function() {
      "fold_change_table_for_selected_genes.csv"
    },
    content = function(file) {
      write.csv(results_3(), file, row.names = FALSE)
    }
  ) 
  
  
  
  output$count_table <- downloadHandler(
    
    filename = function() {
      "PID00022.Count.csv"
    },
    content = function(file) {
      write.csv(counts, file, row.names = FALSE)
    }
  ) 
  
  output$FPKM_table <- downloadHandler(
    
    filename = function() {
      "PID00022.FPKM.csv"
    },
    content = function(file) {
      write.csv(FPKM, file, row.names = FALSE)
    }
  ) 
  
  
  output$plot6 <- renderPlot({
    req(input$select_genes)
    res = table_norm_all()
    selected_genes <- input$select_genes
    p <- get_boxplot_selected(res, selected_genes, sample_info)
    print(p)
  })
  

  res_summary <- df_comparison %>% 
    dplyr::select(comparison, samples, baseline, fold_cutoff, p.adj_cutoff, up, down) %>% 
    dplyr::arrange(comparison)
  
  output$de_summary <-  DT::renderDataTable(
    res_summary
  )
  
  
  output$raw_counts <-  DT::renderDataTable(
    counts
  )
  
  output$FPKM <-  DT::renderDataTable(
    FPKM
  )

  
  output$exp_sample <-  DT::renderDataTable(
    sample_info
  )
  
}