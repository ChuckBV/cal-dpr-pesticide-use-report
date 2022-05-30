#===========================================================================#
# chemicals.R
#
# Examine files in the yearly CA Dept. Pest. Reg. Pesticide use report for
# 2018 (from https://files.cdpr.ca.gov/pub/outgoing/pur_archives/ )
# 
#===========================================================================#

library(tidyverse)

list.files("./pur2018") # demonstrates valid path
# [1] "adjuvant_info.pdf"      "cd_doc.pdf"             "changes2018.txt"        "chem_cas.txt"          
# [5] "chemical.txt"           "county.txt"             "debug.log"              "diagram.pdf"           
# [9] "error_descriptions.txt" "errors_readme.pdf"      "errors_readme.txt"      "errors2018.txt"        
# [13] "ex_sum_18.pdf"          "formula.txt"            "outlier2018.txt"        "product.txt"           
# [17] "qualify.txt"            "qualify_readme.txt"     "site.txt"               "site2.txt"             
# [21] "udc18_01.txt"           "udc18_02.txt"           "udc18_03.txt"           "udc18_04.txt"          
# [25] "udc18_05.txt"           "udc18_06.txt"           "udc18_07.txt"           "udc18_08.txt"          
# [29] "udc18_09.txt"           "udc18_11.txt"           "udc18_12.txt"           "udc18_13.txt"          
# [33] "udc18_14.txt"           "udc18_15.txt"           "udc18_16.txt"           "udc18_17.txt"          
# [37] "udc18_18.txt"           "udc18_19.txt"           "udc18_20.txt"           "udc18_21.txt"          
# [41] "udc18_22.txt"           "udc18_23.txt"           "udc18_24.txt"           "udc18_25.txt"          
# [45] "udc18_26.txt"           "udc18_28.txt"           "udc18_29.txt"           "udc18_30.txt"          
# [49] "udc18_31.txt"           "udc18_32.txt"           "udc18_33.txt"           "udc18_34.txt"          
# [53] "udc18_35.txt"           "udc18_36.txt"           "udc18_37.txt"           "udc18_38.txt"          
# [57] "udc18_39.txt"           "udc18_40.txt"           "udc18_41.txt"           "udc18_42.txt"          
# [61] "udc18_43.txt"           "udc18_44.txt"           "udc18_45.txt"           "udc18_46.txt"          
# [65] "udc18_47.txt"           "udc18_48.txt"           "udc18_49.txt"           "udc18_50.txt"          
# [69] "udc18_51.txt"           "udc18_52.txt"           "udc18_53.txt"           "udc18_54.txt"          
# [73] "udc18_55.txt"           "udc18_56.txt"           "udc18_57.txt"           "udc18_58.txt"
    # Two county files (udc19_*.txt) omitted because of file size restrictions 
    # on Github

### Characterize files with chemical information. See page 14 in 
### "./pur18/cd_doc.pdf" for relationships. Product connects with chem_cas
### and chemical through a field in the usde data (udc18_*.txt) files.

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

### Read in copy-and-past text files
almond_chems <- read_csv("now-almond-insecticide2.txt")
    # Source https://www2.ipm.ucanr.edu/agriculture/almond/Navel-Orangeworm/
pist_chems <- read_csv("now-pistachio-insecticide2.txt")
    # Source https://www2.ipm.ucanr.edu/agriculture/pistachio/Navel-Orangeworm/
walnut__chems <- read_csv("now-walnut-insecticide2.txt")
    # Source https://www2.ipm.ucanr.edu/agriculture/walnut/Navel-Orangeworm/

nut_chems <- bind_rows(list(almond_chems,pist_chems,walnut__chems))
nut_chems
# A tibble: 40 x 2
#   RecNo chemname                             
#   <dbl> <chr>                                
# 1     1 (Z,Z)-11,13-HEXADECADIENAL           
# 2     1 METHOXYFENOZIDE       
    # RecNo was a constant added to make the file work with read_csv

    # Reduce to 1 obs per chem name
nut_chems <- nut_chems %>% 
  group_by(chemname) %>% 
  summarise(nObs = n())

    # Get unique chem names into a character vetor
chem_list <- nut_chems$chemname

### Non-BT insecticides
chem_list_out1 <- chemicals %>% 
  filter(chemname %in% chem_list)
    # Kicks out list of desired chemicals with DPR chem_code and chemalpha_cd

### Bt Kurstaki formulations
chem_list_out2 <- chemicals %>% 
  filter(str_detect(chemname,"KURSTAKI"))
    # Apparently more complicated for Bt

### Combine data frames and output
chem_list_out <- rbind(chem_list_out1,chem_list_out2)

    # Add Chemical Abstract Number (CAS Number)
chem_list_out <- left_join(chem_list_out,chem_cas)

write.csv(chem_list_out,"chem_list_out.csv", row.names = FALSE)  

