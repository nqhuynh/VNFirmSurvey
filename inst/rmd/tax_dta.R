library(here)
library(data.table)

dta_list <- list(
      here("inst", "extdata",
                        "Stata_2000",
                        "dn2000.dta"),
      here("inst", "extdata",
           "Stata_2001",
           "dn2001.dta"),
      here("inst", "extdata",
           "Stata_2002",
           "dn2002.dta"),
      here("inst", "extdata",
           "Stata_2003",
           "dn2003.dta"),
      here("inst", "extdata",
           "Stata_2004",
           "dn2004.dta"),
      here("inst", "extdata",
           "Stata_2005",
           "dn2005.dta"),
      here("inst", "extdata",
           "Stata_2006",
           "dn2006.dta"),
      here("inst", "extdata",
           "Stata_2007",
           "dn2007.dta"),
      here("inst", "extdata",
           "Stata_2008",
           "dn2008.dta"),
      here("inst", "extdata",
           "Stata_2009",
           "dn2009.dta"),
      here("inst", "extdata",
           "Stata_2010",
           "dn2010.dta"),
      here("inst", "extdata",
           "Stata_2011",
           "dn2011_mst.dta"),
      here("inst", "extdata",
           "Stata_2012",
           "dn2012_mst.dta"),
      here("inst", "extdata",
           "Stata_2013",
           "dn2013_mst.dta"),
      here("inst", "extdata",
           "Stata_2014",
           "dn2014.dta"),
      here("inst", "extdata",
           "Stata_2015",
           "dn2015.dta")
)

years <- c(2000:2015)

TaxData <- function(dn_list){
      ### read the Stata files
      dn_dta <- lapply(dta_list, function(x)
            haven::read_dta(file = x,
                            encoding = "latin1"))

      dn_dta <- lapply(dn_dta, data.table::setDT)

      ### select columns
      dn_dta <- mapply(function(x, y) x[, svyear := y],
                           dn_dta,
                           years, SIMPLIFY = F)

      harmonize_tax <- function(dta, svyear){
            if (svyear == 2000){
                  dta <- dta[, .(svyear,
                                 madn,
                                 #taxcode = ma_thue,
                                 tot_tax = nns1013,
                                 enterprise_tax = nns10143
                  )]
            } else if (svyear == 2001){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns13,
                                 enterprise_tax = nns63
                  )]
            } else if (svyear %in% c(2002, 2003) ){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns13,
                                 enterprise_tax = nns73,
                                 income_tax_inc_past = kqkd11
                  )]

            }else if (svyear == 2004){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns13,
                                 enterprise_tax = nns73
                                 #income_tax_inc_past = kqkd12
                  )]
            }else if (svyear == 2005){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns13,
                                 enterprise_tax = nns73,
                                 income_tax_inc_past = kqkd12
                  )]
            }else if (svyear == 2006){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12
                  )]
            }else if (svyear == 2007){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12,
                                 enterprise_tax = nns72
                  )]
            }
            else if (svyear == 2008){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12,
                                 income_tax_inc_past = kqkd13
                  )]
            }else if (svyear >= 2009 & svyear <= 2010){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12,
                                 income_tax_inc_past = kqkd18
                  )]
            } else if (svyear == 2011){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12,
                                 income_tax_inc_past = kqkd21
                  )]
            } else if (svyear > 2011 & svyear <= 2014){
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12,
                                 income_tax_inc_past = kqkd23,
                                 income_tax_this_year = kqkd24
                  )]
            } else {
                  dta <- dta[, .(svyear,
                                 madn,
                                 # taxcode = ma_thue,
                                 tot_tax = nns12,
                                 income_tax_inc_past = kqkd21,
                                 income_tax_this_year = kqkd22
                  )]
                  }

            return(dta)
      }


      tax_dta <- mapply(harmonize_tax,
                        dn_dta,
                           years,
                           SIMPLIFY = F)

      tax_dta <- data.table::rbindlist(tax_dta, fill = TRUE)

      return(tax_dta)

}


tax_dta <- TaxData(dn_list = dta_list)

saveRDS(tax_dta,
        file = "/Users/nghiem/Documents/papers/TradeSOE/data/tax_dta.rds")


tax_dta[, .(mean(tot_tax, na.rm  = T),
            mean(income_tax_inc_past, na.rm  = T),
            mean(enterprise_tax, na.rm  = T),
            mean(income_tax_this_year, na.rm  = T)), by = svyear]
