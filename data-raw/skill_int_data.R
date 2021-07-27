## code to prepare `skill_int_data` dataset goes here

library(haven)
library(dplyr)
library(data.table)
library(labelled)

# retrieve paths to doanh nghiep info 2001
dn2001.file <- system.file(
      "extdata",
      "Stata_2001",
      "dn2001.dta",
      package = "VNFirmSurvey"
)

# read the Stata files
dn_2001_dta <- read_dta(dn2001.file)

# glimpse(dn_2001_dta)

# select variables in headquarters

skill_01_dta <- setDT(dn_2001_dta)[, .(tinh,
                                       macs,
                                       madn,
                                       ma_thue,
                                       total_L = ldc11,
                                       PhD = ldc21,
                                       Masters = ldc31,
                                       Uni = ldc41,
                                       College = ldc51,
                                       Pro_secd = ldc61,
                                       technical = ldc71,
                                       high_skill_tec = ldc81,
                                       other_labor =ldc91)]

skill_01_dta
# save the dataframe as an .rda file in package/data/

usethis::use_data(skill_01_dta, overwrite = TRUE)
