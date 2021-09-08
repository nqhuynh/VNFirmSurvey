#' @title Firm entry and exit status between 2001 and 2007
#' @description Input a list of enterprise dn files and
#' get firm entry, exit, incumbent status between 2001 and 2007
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly, first 2001 then 2007.
#' @rdname EntryExit
#' @import data.table
#' @export

EntryExit <- function(dta_list){

      dynamic_dta <- VNFirmSurvey::getLocation(dta_list)

      temp <- dynamic_dta[,
                          status_07 := fcase(
            madn %in%  intersect(dynamic_dta[svyear == 2001]$madn,
                                 dynamic_dta[svyear == 2007]$madn), "incumbent",
            madn %in%  setdiff(dynamic_dta[svyear == 2001]$madn,
                                 dynamic_dta[svyear == 2007]$madn), "exit",
            madn %in%  setdiff(dynamic_dta[svyear == 2007]$madn,
                               dynamic_dta[svyear == 2001]$madn), "entrant"
      )]

      temp[, .N, by = status_07]

      # DataExplorer::profile_missing(geo_dta)

      ### If need be, Remove 1 missing xa, huyen.
      #wage_dta <- stats::na.omit(wage_dta)

      ## Label variables
      var_label(geo_dta) <- list(svyear = "Year",
                                 tinh = "Province",
                                 macs = "Firm ID",
                                 madn = "Another firm ID?",
                                 ma_thue = "Tax ID",
                                 xa = "commune",
                                 huyen = "district")


      if (!missing(store_dir)){

            saveRDS(geo_dta,
                    file = store_dir)

            return(print(paste("Data is stored at "), store_dir))
      }else{

            return(geo_dta)
      }
}
