# Using dplyr to extract information from the Pesticide Use Report (RRP)

From the early 2000s, The California Department of Pesticide Research has 
provided data on statewide pesticide applications as a series of data tables
intended as part of a relational database that could be queried by SQL. 
For part of this period these data were distributed as CD-ROMs, and the size
of the data set was kept within the limits of that medium. As of 2022, these
are available to be downloaded as ZIP files (see 
https://calpip.cdpr.ca.gov/main.cfm).

As of March 2022, the 2018 data set is the most recent available. Those files 
are in the accompanying directory, ./pur2018. The relationship between these 
files is described in "diagram.pdf". Note that most of the text files are, in
fact, comma-delimited data files
 - udc18_01.txt to udc18_58.txt are actual application data, with each files
 corresponding to an individual county.
 - product.txt describes pesticides
 - site.txt matches "site_code" and site_name

## Important Notes
 
The name of crops is found in site_name.

Counties 10 and 27 were over 50MB for 2018. For this proof of concept they were
dropped. For practical use, they would need to be split or arrangements would
need to be make for large file storage.