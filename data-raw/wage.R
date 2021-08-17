## code to prepare `wage` dataset goes here

### retrieve data to doanh nghiep

dn2001.file <- system.file(
      "extdata",
      "Stata_2001",
      "dn2001.dta",
      package = "VNFirmSurvey"
)


dn2007.file <- system.file(
      "extdata",
      "Stata_2007",
      "dn2007.dta",
      package = "VNFirmSurvey"
)

### read the Stata files

if (file.exists(dn2001.file) & file.exists(dn2007.file)){
      dn_dta <- lapply(list(dn2001.file, dn2007.file), read_dta)
}else{
      print("File dn2001.file or dn2007.dta does not exist. Consider using InputData function to copy correct files ?InputData")
}


### select columns


wage_dta <- mapply(function(x, y) setDT(x)[, svyear := y],
                   dn_dta,
                   c(2001, 2007), SIMPLIFY = F)

wage_dta <- lapply(wage_dta, function(x)  x[, .(  svyear,
                                                  tinh, macs, madn,   ma_thue,
                                                  total_L =  ld13,
                                                  wage_bill = tn1,
                                                  ave_wage = tn1/ld13)])

wage_dta <- rbindlist(wage_dta)

update_columns(wage_dta, c("tinh", "madn", "macs", "ma_thue"), as.factor)

### Remove NAs rows in total_L, wage_bill, and ave_wage
wage_dta <- na.omit(wage_dta)

### Remove firms with zero total labor, only in svyear 2001
wage_dta <- wage_dta[total_L > 0]


usethis::use_data(wage_dta, overwrite = TRUE)
