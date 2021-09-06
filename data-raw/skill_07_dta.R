## code to prepare `skill_07_dta` dataset goes here

### retrieve data to doanh nghiep info 2007
# dn2007.file <- system.file(
#       "extdata",
#       "Stata_2007",
#       "dn2007.dta",
#       package = "VNFirmSurvey"
# )
#
# ### read the Stata files
# if (file.exists(dn2007.file)){
#       dn_2007_dta <- read_dta(dn2007.file)
# }else{
#       print("File dn2007.dta does not exist. Consider using InputData function to copy correct files ?InputData")
# }
#
#
# ### select columns
#
# skill_07_dta <- setDT(dn_2007_dta)[, .(svyear = 2007,
#                                        tinh,
#                                        macs,
#                                        madn,
#                                        ma_thue,
#                                        #endyear_L = ldct11,
#                                        total_L = ld13,
#                                        PhD = ldct91,
#                                        Masters = ldct101,
#                                        Uni = ldct111,
#                                        College = ldct121,
#                                        Pro = ldct131,
#                                        Lterm_voc = ldct141,
#                                        Sterm_voc = ldct151,
#                                        untrained = ldct161)]
#
#
# ### Clean and create skill variables
#
# skill_07_dta <- clean_skill(skill_07_dta)


#usethis::use_data(skill_07_dta, overwrite = TRUE)
