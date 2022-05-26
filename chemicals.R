#===========================================================================#
# chemicals.R
#
# Examine files in the yearly CA Dept. Pest. Reg. Pesticide use repor
# 
#===========================================================================#

library(tidyverse)

list.files("./pur2018") # demonstrates valid path

chem_cas <- read_csv("./pur2018/chem_cas.txt")
chem_cas
# A tibble: 3,202 x 2
# chem_code casnum    
#       <dbl> <chr>     
# 1         1 3383-96-8 
# 2         2 2244-21-5 
# 3         3 107-02-8  

chemicals <- read_csv("./pur2018/chemical.txt")
chemicals
# A tibble: 4,147 x 3
#   chem_code chemalpha_cd chemname                
#       <dbl>        <dbl> <chr>                   
# 1      2254          175 ABAMECTIN               
# 2     92254          176 ABAMECTIN, OTHER RELATED
# 3      1158          200 ABIETIC ACID            
# 4      1212          300 ABIETIC ANHYDRIDE  

product <- read_csv("./pur2018/product.txt")
product
# A tibble: 64,749 x 29
#   prodno mfg_firmno reg_firmno label_seq_no revision_no fut_firmno prodstat_ind product_name
glimpse(product)


#-- 1. Find NOW Mating disruption active ingredient -----------------------
chemicals %>% 
  #filter(str_detect(chemname,"HEXADEC")) -- returns 13 lines
  filter(str_detect(chemname,"13-HEXADECADIENAL"))
# A tibble: 1 x 3
#   chem_code chemalpha_cd chemname                  
#       <dbl>        <dbl> <chr>                     
# 1      5314        78080 (Z,Z)-11,13-HEXADECADIENAL


#-- 2. Get list of active ingredients from UC PMG for nut crops -----------

almond_chems <- read_csv("now-almond-insecticide2.txt")
pist_chems <- read_csv("now-pistachio-insecticide2.txt")
walnut__chems <- read_csv("now-walnut-insecticide2.txt")

nut_chems <- bind_rows(list(almond_chems,pist_chems,walnut__chems))

nut_chems <- nut_chems %>% 
  group_by(chemname) %>% 
  summarise(nObs = n())

chem_list <- nut_chems$chemname

chemicals %>% 
  filter(chem_list %in% chemname)
