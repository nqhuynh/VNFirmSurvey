#' @title Firm entry and exit status
#' @description Input a list of enterprise dn files and
#' get firm entry, exit, incumbent status
#' @param dta_list Input a list of enterprise dn files from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @param base_year A vector of base years to which firms from future survey years are compared. Default is 2001
#' @param years A vector of survey years that need firm status relative to the base_year, should include the base_year
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly, first 2001, 2004 then 2007.
#' @rdname EntryExit
#' @import data.table
#' @export

EntryExit <- function(dta_list, store_dir,
                      base_year = c(2001),
                      years = c(2001, 2004, 2007)){

      dynamic_dta <- VNFirmSurvey::getLocation(dta_list, years)
      for (byear in base_year){
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


      #DataExplorer::profile_missing(dynamic_dta)


      if (!missing(store_dir)){

            saveRDS(dynamic_dta,
                    file = store_dir)

            return(print(paste("Data is stored at "), store_dir))
      }else{

            return(dynamic_dta)
      }
}
