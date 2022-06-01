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
path_dat <- paste0(path_subdir,"/pur2018")
list.files(path_dat) #76 files
# [1] "adjuvant_info.pdf"      "cd_doc.pdf"             "changes2018.txt"       
# [4] "chem_cas.txt"           "chemical.txt"           "county.txt"            
# [7] "debug.log"              "diagram.pdf"            "error_descriptions.txt"
# [10] "errors_readme.pdf"      "errors_readme.txt"      "errors2018.txt"        
# [13] "ex_sum_18.pdf"          "formula.txt"            "outlier2018.txt"       
# [16] "product.txt"            "qualify.txt"            "qualify_readme.txt"    
# [19] "site.txt"               "udc18_01.txt"           "udc18_02.txt"          
# [22] "udc18_03.txt"           "udc18_04.txt"           "udc18_05.txt"          

### Examine files containing crop names
# read_csv("./pur2018/site.txt") # working dir is pur2018 so not needed
read_csv("./site.txt")

mysites <- read_csv("./site2.txt")# add back in pur2018/

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
x <- read_csv("./udc18_01.txt")
x
# A tibble: 36,453 x 35
#   use_no prodno chem_code prodchem_pct lbs_chm_used lbs_prd_used amt_prd_used unit_of_meas acre_planted
#   <dbl>  <dbl>     <dbl>        <dbl>        <dbl>        <dbl>        <dbl> <chr>               <dbl>
# 1 3337041  62971      6004         17.6        0.726        4.12          56   OZ                  10.4 
# 2 3337236  62971      6004         17.6        1.04         5.89          80   OZ                  48.1 

### Get list of input files
file_names <- list.files(path = "./pur2018", #take out this line to run on zachs like the whole thing after bracket
                         recursive = TRUE,
                         pattern = "udc18",
                         full.names = TRUE)

### Combine 56 files of County data
input_files <- read_csv(file_names, id = "file_name")

### Use a list as input, and perform this operation on each file
### Below is quasi-pseudocode. We want output files 1 to 56 for input_files[1]
### to input_files[56]


nut_apps <- input_files %>% 
  filter(site_code %in% c(3001,3009,3011))
glimpse(nut_apps)

### Leaves us with ca. 602,000 records of applications to almond, walnut, and
### pistachio sites in 2018. 35 columns. County names are embedding in file
### names. Next challenges
# 1) Replace "file_name" with County name
list.files()                                      #trying to see where the county file was 
read_csv("county.txt")                            #getting names
county_names <- read_csv("county.txt")            
x <- nut_apps                                     # making coppy of the data 
# x$county_cd[x$county_cd == "01"] <- "ALAMEDA"     #soo this dose work but kinda repetitive not to keen on doing this 58 times

#x$county_cd[x$county_cd == county_names]
# data_merged0 <- merge(x , county_names)
data_merged1 <- left_join(x, county_names, by = c())
#merg files 
#left join 
# ggplot(data = data_merged)+
#   geom_point(mapping = aes(y= county_names)
table(data_merged$county_cd)
table(data_merged$couty_name)#just trying to get an idea on what county had the preferred nuts

list.files(pattern="udc18_")#to get the names of the files 

file.rename(list.files(pattern="udc18_"), 
            str_replace(list.files(pattern="udc18_"), pattern="udc18_", "")) # to simplify the names of the data 
                                                    # ^old pattern      ^ new pattern
# 2) Extract all chem_code used, and link that to a chemical name
read_csv("county.txt")
#narrow to nuts 
table(data_merged$chem_code)
##############useless for now wrong approach 
# ggplot(data = data_merged)+
#   geom_point(mapping = aes(y= chem_code, x = couty_name))

# ggplot(data = data_merged, mapping = aes(y= chem_code, x = couty_name))+
#   geom_boxplot()
#############
old_chem_code  <- read_csv("chemical.txt")
chem_code <- subset(old_chem_code, select= -c(chemalpha_cd))
data_merged1 <- left_join(data_merged, chem_code, by = c())
         
  

### Gets to 2 real-world questions
# 1) What pesticides were used most often? and


# 2) Does which pesticide is most often used vary between counties?




