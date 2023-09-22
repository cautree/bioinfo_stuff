

get_results <- function(res_table, normalized_counts, sample_info){
  
  
  ## Order results by padj values, extract the first 20 genes
  top20_sigOE_genes <- res_table %>% 
    arrange(padj) %>% 	
    pull(gene) %>% 		
    head(n=20)		
  
  
  res_table_sig <- res_table %>% 
    filter(gene %in%top20_sigOE_genes )
  
  ## normalized counts for top 20 significant genes
  top20_sigOE_norm <- normalized_counts %>%
    filter(gene %in% top20_sigOE_genes)
  
  
  # Gathering the columns to have normalized counts to a single column
  first <- grep("\\d+", names(top20_sigOE_norm), value=T)[1]
  last <- tail(grep("\\d+", names(top20_sigOE_norm), value=T),1)
  
  gathered_top20_sigOE <- top20_sigOE_norm %>%
    gather(first:last, 
           key = "samplename", 
           value = "normalized_counts")
  
  meta <- data.frame( samplename = names(normalized_counts)[-1])
  
  meta <- meta %>% 
    left_join(sample_info)
  
  gathered_top20_sigOE <- inner_join(meta, gathered_top20_sigOE)
  
  
  ##for normalized count graph
  p1 <- ggplot(gathered_top20_sigOE) +
    geom_point(aes(x = gene, y = normalized_counts, color = sampletype)) +
    scale_y_log10() +
    xlab("Genes") +
    ylab("Normalized Counts") +
    ggtitle("Top Significant DE Genes") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(plot.title = element_text(hjust = 0.5))
  
  
  
  ##for heatmap
  norm_OEsig <- normalized_counts %>% 
    filter(gene %in% top20_sigOE_genes)
  heat_colors <- brewer.pal(4, "YlOrRd")
  gname = norm_OEsig$gene
  
  norm_OEsig$gene =NULL
  rownames(norm_OEsig) = gname
  
  norm_OEsig = as.data.frame(t(apply(norm_OEsig, 1, scale)))
  
  names(norm_OEsig) = meta$sampletype
  
  ### Set a color palette
  heat_colors <- brewer.pal(4, "YlOrRd")
  
  ### save it into a df for heatmap
  heatmap_df <- norm_OEsig
  
  gathered_top20_sigOE <- gathered_top20_sigOE %>% 
    mutate(gene = as.factor(gene))
  
  p2 <- ggplot(gathered_top20_sigOE) +
    geom_boxplot(aes(x = sampletype, y = normalized_counts,color= gene)) +
    scale_y_log10() +
    xlab("Genes") +
    ylab("Normalized Counts") +
    ggtitle("Top Significant DE Genes") +
    facet_wrap(.~gene, nrow = 5, scales = "free_y")+
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(plot.title = element_text(hjust = 0.5))
  
  return(list( count_plot=p1, heatmap_df=heatmap_df, result_table = res_table, boxplot = p2))
  
}



get_boxplot_selected <- function(normalized_counts, selected, sample_info){
  
  df_norm <- normalized_counts %>%
    filter(gene %in% selected)
  
  first <- grep("\\d+", names(df_norm), value=T)[1]
  last <- tail(grep("\\d+", names(df_norm), value=T),1)
  
  # Gathering the columns to have normalized counts to a single column
  gathered_norm <- df_norm %>%
    gather(first:last, key = "samplename", value = "normalized_counts")
  
  meta <- data.frame( samplename = names(df_norm)[-1])

  
  meta <- meta %>% 
    left_join(sample_info)
  
  gathered_norm <- inner_join(meta, gathered_norm)
  
  p <- ggplot(gathered_norm) +
    geom_boxplot(aes(x = sampletype, y = normalized_counts,color= gene)) +
    scale_y_log10() +
    xlab("Genes") +
    ylab("Normalized Counts") +
    ggtitle("Normalized Counts for selected genes") +
    facet_wrap(.~gene, nrow = 5, scales = "free_y")+
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(plot.title = element_text(hjust = 0.5))
  
  return(p)
}


get_the_boxplot_df <- function(df_norm, selected, sample_info){
  
  df_norm <- df_norm %>%
    filter(gene %in% selected)
  
  sample_info_s <- sample_info %>% 
    select(samplename, sampletype) %>% 
    filter( samplename %in% names(df_norm)) %>% 
    distinct()
  col_order <- c("gene", sample_info_s$samplename)
  df_norm <- df_norm[, col_order]
  names(df_norm) <- c("gene", sample_info_s$sampletype)
  return(df_norm)
  
}


get_PCA_plots <- function(rld, sample_info){
  
  
  rld_mat <- assay(rld)
  pca <- prcomp(t(rld_mat))
  
  
  df <- pca$x %>% 
    as.data.frame() %>% 
    dplyr::add_rownames(var = "samplename") %>% 
    left_join(sample_info) %>% 
    mutate(sampletype = as.factor(sampletype))

  p1 <- df %>% 
    ggplot( aes(x=PC1, y=PC2,  color= sampletype, shape=sampletype ))+
    geom_point(size=4)+
    scale_shape_manual(values=1:nlevels(df$sampletype)) +
    geom_text_repel(aes(label= samplename), show.legend = FALSE)+
    theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"))
  
  p2 <- df %>% 
    ggplot( aes(x=PC2, y=PC3,  color= sampletype, shape=sampletype ))+
    geom_point(size=4)+
    scale_shape_manual(values=1:nlevels(df$sampletype)) +
    geom_text_repel(aes(label= samplename),  show.legend = FALSE)+
    theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"))
  
  
  figure <- ggarrange(p1, p2,
                      labels = c("A", "B"),
                      ncol = 1, nrow = 2)
 return(figure)
  
}


