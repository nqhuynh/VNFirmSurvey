
#' @title Harmonize firm identifiers to create unique identifiers for panel firms from 2001-2018
#' @description Input geographic data, stacked across years.
#' @param geo_dta geographic firm data. See getLocation function.
#' @return A cleaned data frame with year, geographic location (not harmonized), sector (not harmonized),
#' unique tax id, and unique firm id
#' @details The input data should include years 2015 to 2017 where most changes happen for firm IDs
#' @import data.table tidytable
#' @export


harmonize_firmID <- function(geo_dta){

      dynamic_dta <- EntryExit(geo_dta,
                               base_year = 2015,
                               years = c(2016:2018)
                               )

      dta <- merge(dynamic_dta[svyear == 2015 , .(firm_id,  unique_tax_id)],
                   dynamic_dta[svyear > 2015 &
                                     (status_2016rel_2015 == "incumbent" |
                                            status_2017rel_2015 == "incumbent"), .(svyear,
                                                                                   unique_tax_id)],
                   by = "unique_tax_id")[, firm_2015_id := firm_id]

      dta <- merge(dta[, .(svyear, unique_tax_id, firm_2015_id)],
                   dynamic_dta,
                   by = c("svyear", "unique_tax_id"),
                   all.y =  T)

      dta<- dta[, firm_id := case.(
                          svyear < 2016, firm_id,
                          svyear >= 2016 &
                                (status_2016rel_2015 == "incumbent" |
                                       status_2017rel_2015 == "incumbent"|
                                    status_2018rel_2015 == "incumbent"), firm_2015_id,
                          default = unique_tax_id
                    )]
      return(dta)
}
