#' @title Firm entry and exit status
#' @description Input geo_data and
#' get firm entry, exit, incumbent status
#' @param geo_dta Input cleaned geographic data, stacked over years.
#' @param harmonized Input True if the input geo_dta has firm ID harmonized.
#' @param base_year A vector of base years to which firms from future survey years are compared. Default is 2001
#' @param years A vector of survey years that need firm status relative to the base_year, should include the base_year
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered in an ascending order.
#' @rdname EntryExit
#' @import data.table
#' @export

EntryExit <- function(geo_dta,
                      harmonized,
                      base_year,
                      years){

      dynamic_dta <- geo_dta  # getLocation(dta_list, years)


      for (byear in base_year){
         if (byear < 2015 | (harmonized = T) ){
            for (j in years){
                  if (j > byear){
                        dynamic_dta[svyear >= byear, paste0("status_", j, "rel_", byear) :=  fcase(
                              (firm_id %in%  intersect(dynamic_dta[svyear == byear]$firm_id,
                                                    dynamic_dta[svyear == j]$firm_id)), "incumbent",
                              firm_id %in%  setdiff(dynamic_dta[svyear == byear]$firm_id,
                                                 dynamic_dta[svyear == j]$firm_id), "exit",
                              firm_id %in%  setdiff(dynamic_dta[svyear == j]$firm_id,
                                                 dynamic_dta[svyear == byear]$firm_id), "entrant")]
                  }
            }
         }
         else{
            for (j in years){
                  if (j > byear){
                     dynamic_dta[svyear >= byear, paste0("status_", j, "rel_", byear) :=  fcase(
                        (unique_tax_id %in%  intersect(dynamic_dta[svyear == byear]$unique_tax_id,
                                                       dynamic_dta[svyear == j]$unique_tax_id)), "incumbent",
                        unique_tax_id %in%  setdiff(dynamic_dta[svyear == byear]$unique_tax_id,
                                                    dynamic_dta[svyear == j]$unique_tax_id), "exit",
                        unique_tax_id %in%  setdiff(dynamic_dta[svyear == j]$unique_tax_id,
                                                    dynamic_dta[svyear == byear]$unique_tax_id), "entrant")]
                  }
               }
         }
      }

      #DataExplorer::profile_missing(dynamic_dta)
      return(dynamic_dta)

}
