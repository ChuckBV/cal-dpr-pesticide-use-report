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
read_csv("./pur2018/site.txt") # working dir is pur2018 so not needed
# read_csv("./site.txt")

mysites <- read_csv("./pur2018/site2.txt")# add back in pur2018/

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
x <- read_csv("./pur2018/udc18_01.txt")
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
read_csv("./pur2018/county.txt")                            #getting names
county_names <- read_csv("./pur2018/county.txt")            
# x$county_cd[x$county_cd == "01"] <- "ALAMEDA"     #soo this dose work but kinda repetitive not to keen on doing this 58 times

#x$county_cd[x$county_cd == county_names]
# data_merged0 <- merge(x , county_names)
#data_merged1 <- left_join(x, county_names, by = c())

data_merged1 <- left_join(county_names,nut_apps) # County names now in file

x <- data_merged1 %>% 
  group_by(couty_name) %>% 
  summarise(nObs = n()) %>% 
  arrange(desc(nObs)) %>% 
  filter(nObs > 1000) 
x
# A tibble: 17 x 2
#   couty_name   nObs
#   <chr>       <int>
# 1 STANISLAUS  95494
# 2 KERN        80671
# 3 SAN JOAQUIN 63389

x <- x %>% 
  mutate(county_name = fct_infreq(couty_name)) 
x

### Plot applications to nut crop by county, top 17 counties
ggplot(x, aes(x = county_name, y = nObs)) +
  geom_col() +
  coord_flip()
  # refinenment need. Replace x and y labels. Get bars to sore
  # by nObs



# 2) Extract all chem_code used, and link that to a chemical name

old_chem_code  <- read_csv("./pur2018/chemical.txt")
chem_code <- subset(old_chem_code, select= -c(chemalpha_cd))
    # Could also be accomplished with dplyr::select() or with df[,c(1,3)]
data_merged2 <- left_join(chem_code,data_merged1)
data_merged2         
# A tibble: 432,728 x 38
#   chem_code chemname  county_cd couty_name file_name            use_no prodno prodchem_pct lbs_chm_used lbs_prd_used amt_prd_used unit_of_meas acre_planted
#       <dbl> <chr>     <chr>     <chr>      <chr>                 <dbl>  <dbl>        <dbl>        <dbl>        <dbl>        <dbl> <chr>               <dbl>
# 1      2254 ABAMECTIN 01        ALAMEDA    ./pur2018/udc18_01.~ 2.01e6  62903         8           9.87        123.        2000    OZ                  500  
# 2      2254 ABAMECTIN 01        ALAMEDA    ./pur2018/udc18_01.~ 2.01e6  62903         8           0.560         7.00       114.   OZ                   28.4
# 3      2254 ABAMECTIN 01        ALAMEDA    ./pur2018/udc18_01.~ 2.01e6  62903         8           1.58         19.7        320    OZ                   80    

### Gets to 2 real-world questions
# 1) What pesticides were used most often? and

data_merged2 %>% 
  group_by(chem_code,chemname) %>% 
  summarise(nObs = n()) %>% 
  filter(nObs > 1000) %>% 
  arrange(desc(nObs))



# 2) Does which pesticide is most often used vary between counties?




