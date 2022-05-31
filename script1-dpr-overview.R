#===========================================================================#
# script1-dpr-overview.R
#
# Examine files in the yearly CA Dept. Pest. Reg. Pesticide use repor
# 
#===========================================================================#

library(tidyverse)

list.files() # narrows to 2 subdirectories

list.files("./pur2018") # demonstrates valid path

# path for second level DPR subdirectory containing 2018 data
list.files("./pur2018") #76 files
# [1] "adjuvant_info.pdf"      "cd_doc.pdf"             "changes2018.txt"       
# [4] "chem_cas.txt"           "chemical.txt"           "county.txt"            
# [7] "debug.log"              "diagram.pdf"            "error_descriptions.txt"
# [10] "errors_readme.pdf"      "errors_readme.txt"      "errors2018.txt"        
# [13] "ex_sum_18.pdf"          "formula.txt"            "outlier2018.txt"       
# [16] "product.txt"            "qualify.txt"            "qualify_readme.txt"    
# [19] "site.txt"               "udc18_01.txt"           "udc18_02.txt"          
# [22] "udc18_03.txt"           "udc18_04.txt"           "udc18_05.txt"          

### Examine files containing crop names
read_csv("./pur2018/site.txt")

mysites <- read_csv("./pur2018/site2.txt")
mysites
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

### Example of county-level site data for 2018

### Get list of input files
file_names <- list.files(path = "./pur2018", 
                         recursive = TRUE,
                         pattern = "udc18",
                         full.names = FALSE)

### Combine 56 files of County data
input_files <- read_csv(file_names, id = "file_name")

### Use a list as input, and perform this operation on each file
### Below is quasi-pseudocode. We want output files 1 to 56 for input_files[1]
### to input_files[56]

nut_apps <- input_files %>% 
  filter(site_code %in% c(3001,3009,3011))
nut_apps

glimpse(nut_apps)

### Leaves us with ca. 602,000 records of applications to almond, walnut, and
### pistachio sites in 2018. 35 columns. County names are embedding in file
### names. Next challenges
# 1) Replace "file_name" with County name
# 2) Extract all chem_code used, and link that to a chemical name

### Gets to 2 real-world questions
# 1) What pesticides were used most often? and
# 2) Does which pesticide is most often used vary between counties?