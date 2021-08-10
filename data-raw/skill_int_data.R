## code to prepare `skill_int_data` dataset goes here

### retrieve data to doanh nghiep info 2001
dn2001.file <- system.file(
      "extdata",
      "Stata_2001",
      "dn2001.dta",
      package = "VNFirmSurvey"
)

### read the Stata files
dn_2001_dta <- read_dta(dn2001.file)

### select variables in headquarters

skill_01_dta <- setDT(dn_2001_dta)[, .(tinh,
                                       macs,
                                       madn,
                                       ma_thue,
                                       total_L_head = ldc11,
                                       PhD = ldc21,
                                       Masters = ldc31,
                                       Uni = ldc41,
                                       College = ldc51,
                                       Pro_secd = ldc61,
                                       technical = ldc71,
                                       high_skill_tec = ldc81,
                                       other_labor =ldc91)]


### Update columns
update_columns(skill_01_dta, c("tinh", "madn", "macs", "ma_thue"), as.factor)

### Deal with missing variables

# Apart from missing data for total_L_head,
# I interpret missing data for other skill variables as having zero observations.
# I also drop 8 firms with missing total_L_head data (less than 0.001%).


set_missing(skill_01_dta, 0L, exclude = "total_L_head")

skill_01_dta <- na.omit(skill_01_dta)

### Remove firms with zero total_L_head (only 2)
skill_01_dta <- skill_01_dta[total_L_head > 0]


### Construct skill intensity (SI) measures

# A sub category of high skill technical workers among technical workers can create confusion.
# SI1: Let's ignore it for now and define skilled workers as all workers with technical degree and more than high school degree.
# Then, I add other SI measures together

skill_01_dta[, SI_1 := ((PhD + Masters + Uni + College + Pro_secd + technical)/ total_L_head)]

skill_01_dta[, SI_2 := ((PhD + Masters + Uni + College + high_skill_tec)/ total_L_head)]

skill_01_dta[, SI_3 := ((PhD + Masters + Uni + high_skill_tec)/ total_L_head)]

skill_01_dta[, SI_4 := ((PhD + Masters + Uni)/ total_L_head)]

### Drop columns

drop_columns(skill_01_dta,
             c("PhD", "Masters", "Uni", "College", "Pro_secd", "technical",
                             "high_skill_tec", "other_labor"))


### save the dataframe as an .rda file in package/data/

usethis::use_data(skill_01_dta, overwrite = TRUE)
