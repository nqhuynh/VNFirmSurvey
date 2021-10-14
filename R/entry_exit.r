#' @title Firm entry and exit status
#' @description Input geo_data and
#' get firm entry, exit, incumbent status
#' @param geo_dta Input cleaned geographic data, stacked over years.
#' @param base_year A vector of base years to which firms from future survey years are compared. Default is 2001
#' @param years A vector of survey years that need firm status relative to the base_year, should include the base_year
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered in an ascending order.
#' @rdname EntryExit
#' @import data.table
#' @export

EntryExit <- function(geo_dta,
                      base_year,
                      years){

      dynamic_dta <- geo_dta  # getLocation(dta_list, years)

      #(harmonized = T)
      for (byear in base_year){
         if (byear < 2015 ){
            for (j in years){
                  if (j > byear){
                        dynamic_dta[svyear >= byear, paste0("status_", j, "rel_", byear) :=  fcase(
                              (madn %in%  intersect(dynamic_dta[svyear == byear]$madn,
                                                    dynamic_dta[svyear == j]$madn)), "incumbent",
                              madn %in%  setdiff(dynamic_dta[svyear == byear]$madn,
                                                 dynamic_dta[svyear == j]$madn), "exit",
                              madn %in%  setdiff(dynamic_dta[svyear == j]$madn,
                                                 dynamic_dta[svyear == byear]$madn), "entrant")]
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
