library(rlang)
library(purrr)

get_plot = function(spm){
  label = spm
  spm = sym(spm)
 p= df %>% 
    ggplot(aes(order,  !!spm, color = plate)) +
    geom_point( size = 0.7)+
    facet_wrap(~QCTYPE, nrow=4, scales = "free_y") 
 print(p)
  ggsave( paste("CTSC_not_fixed_y_w_exp/",label, ".png", sep="") )
  
}

purrr::walk( spm_list, get_plot)