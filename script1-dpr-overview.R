#===========================================================================#
# script1-dpr-overview.R
#
# Examine files in the yearly CA Dept. Pest. Reg. Pesticide use repor
# 
#===========================================================================#

library(tidyverse)

### Get paths to subdirectories

# I don't like using non-relative paths, but it seems necessary in this case

# Root for the local git repository 
path_default <- getwd() 
path_default
# [1] "C:/Users/Charles.Burks/my_git/Etude3
list.files(path_default, pattern = "Y22-") # narrows to 2 subdirectories

# path for Etude3 subdirectory containing DPR files
path_subdir <- paste0(path_default,"/Y22-03-07-cal_dpr_pest_use_report")
path_subdir
# [1] "C:/Users/Charles.Burks/my_git/Etude3/Y22-03-07-cal_dpr_pest_use_report"
list.files(path_subdir) # demonstrates valid path

# path for second level DPR subdirectory containing 2018 data
path_dat <- paste0(path_subdir,"/pur2018")
list.files(path_dat)
# [1] "adjuvant_info.pdf"      "cd_doc.pdf"             "changes2018.txt"       
# [4] "chem_cas.txt"           "chemical.txt"           "county.txt"            
# [7] "debug.log"              "diagram.pdf"            "error_descriptions.txt"
# [10] "errors_readme.pdf"      "errors_readme.txt"      "errors2018.txt"        
# [13] "ex_sum_18.pdf"          "formula.txt"            "outlier2018.txt"       
# [16] "product.txt"            "qualify.txt"            "qualify_readme.txt"    
# [19] "site.txt"               "udc18_01.txt"           "udc18_02.txt"          
# [22] "udc18_03.txt"           "udc18_04.txt"           "udc18_05.txt"          

### Examine files containing crop names



mysites <- read.csv(paste0(path_dat,"/site.txt2"))
#   site_code site_name
# 1      3000      NUTS
# 2      3001    ALMOND
# 3      3009    WALNUT
# 4      3011 PISTACHIO

#    unintuitively, site.txt actually contains crop names and codes. site2.txt
#    is the original file manually trimmed to just nut crops. Note that, *.txt
#    extension not withstanding, this is a csv file.

### Use site_code to extract only almond, walnut and pistachio from 
### udc18_01.txt, udc18_02.txt, udc18_03.txt. Append extracted files into 
### a single data frame

x <- read_csv(paste0(path_dat,"/udc18_01.txt"))
#    read application data for 1 of 58 counties

select(x,site_loc_id) # 
#    35 variables! site_loc_id is a key one, examine it
#    reveals that site_loc_id defaults to character

x$site_loc_id <- as.numeric(x$site_loc_id)
#    convert charcter to numeric. NAs introduced--how many?

sum(is.na(x$site_loc_id))/nrow(x)
#    lost 14% of observations. Important? Too soon to tell

y <- filter(x,site_loc_id %in% c(3001,3009,3011))
