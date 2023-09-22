get_data <- function( selected_samples){
 
  
  if(selected_samples== "HEK_D04_vs_IL12_D04"){
    
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A5678.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A5678.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A5678.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A5678.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
    
  } else if (selected_samples== "HEK_D04_vs_PrX_D04"){
    
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A56910.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A56910.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A56910.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A56910.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  } else if (selected_samples== "IL12_D04_vs_PrX_D04"){
    
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A78910.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A78910.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A78910.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A78910.csv")
    
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  } else if (selected_samples== "IL12_perfusion_D13_vs_IL12_D04"){
    
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A178.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A178.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A178.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A178.csv")

    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  } else if (selected_samples== "IL12_perfusion_D07_vs_IL12_D04"){
    
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A278.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A278.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A278.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A278.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  } else if (selected_samples== "PrX_perfusion_D24_vs_PrX_D04"){
    
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A3910.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A3910.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A3910.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A3910.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  } else if (selected_samples== "PrX_perfusion_D06_vs_PrX_D04"){
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A4910.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A4910.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A4910.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A4910.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  }  else if (selected_samples== "PrX_perfusion_D06_vs_Exosome"){
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A41112.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A41112.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A41112.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A41112.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
    
  }  else if (selected_samples== "PrX_perfusion_D24_vs_Exosome"){
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A31112.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A31112.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A31112.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A31112.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
    
  }   else if (selected_samples== "IL12_perfusion_vs_PrX_perfusion"){
    de_genes <- data.table::fread("data/DE_genes_sig/DEseq_A1234.csv")
    df_norm <- data.table::fread("data/normalized_count_sig/normalized_count_A1234.csv")
    
    de_genes_2 <- data.table::fread("data/DE_genes/DEseq_A1234.csv")
    df_norm_2 <- data.table::fread("data/normalized_count/normalized_count_A1234.csv")
    
    de_genes <- as.data.frame(de_genes)
    df_norm <- as.data.frame(df_norm)
    de_genes_2 <- as.data.frame(de_genes_2)
    df_norm_2 <- as.data.frame(df_norm_2)
  }
  
  
  return(list(de_genes = de_genes, df_norm = df_norm, de_genes_2 = de_genes_2, df_norm_2 = df_norm_2))
  
  
}

