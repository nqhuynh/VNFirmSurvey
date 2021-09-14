
#' @title Firm ownership type 2001, 2004, and 2007.
#' @description Input a list of enterprise dn files and
#' get location data for firms 2001, 2004 and 2007
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @param years A vector of survey years that correspond to the raw data list dn from GSO dta_list
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly to match with the years vector of survey years.
#' @rdname ownership
#' @import data.table
#' @export

ownership <- function(dta_list,
                        years = c(2001),
                        store_dir){

      ### read the Stata files
      dn_dta <- lapply(dta_list, haven::read_dta)
      dn_dta <- lapply(dn_dta, setDT)

      ### select columns

      owner_data <- mapply(function(x, y) x %>% dplyr::mutate(svyear = y),
                        dn_dta,
                        years, SIMPLIFY = F)

      owner_data[[1]][lhdn == 14 , .((ft_von))]
      owner_data[[1]][svyear == 2001, .(madn, lhdn, ft_von)
                      ][, .N, by = lhdn
                        ][order(lhdn)]

      # 1 - Central SOE
      # 2 - Local SOE
      # 3 - Collective
      # 4 - Private enterprise
      # 5 - Partnership company
      # 6 - LLC with 1 state member
      # 7 - Private LLC with 1 member
      # 8 - JSC with state Use ft_von > 50
      # 9 - Private LLC with 2+ members
      # 10 - JSC with state capital
      # 11 - JSC without state capital
      # 12 - 100% foreign
      # 13 - Foreign with state partner
      # 14 - Foreign with other partner
      geo_dta <- lapply(geo_dta, function(x)  setDT(x)[, .( svyear,
                                                            macs, madn,
                                                            ma_thue,
                                                            ma_thue2,
                                                            xa,
                                                            huyen,
                                                            tinh)])

      geo_dta <- data.table::rbindlist(geo_dta)

      DataExplorer::update_columns(geo_dta,
                                   c( "madn", "macs", "ma_thue",
                                      "ma_thue2", "xa", "huyen", "tinh"), as.factor)

      #DataExplorer::profile_missing(geo_dta)

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
