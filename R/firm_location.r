

#' @title Firm geographic location 2001 and 2007, Not harmonized
#' @description Input a list of enterprise dn files and
#' get location data for firms between 2001 and 2007
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly, first 2001 then 2007.
#' @rdname getLocation
#' @import data.table
#' @export

dta_list <- list(here("inst", "extdata",
                      "Stata_2001",
                      "dn2001.dta"),
                 here("inst", "extdata",
                      "Stata_2007",
                      "dn2007.dta") )

temp<- getLocation(dta_list)

getLocation <- function(dta_list, store_dir){

      ### read the Stata files
      dn_dta <- lapply(dta_list, haven::read_dta)
      dn_dta <- lapply(dn_dta, setDT)
      # if (all(lapply(dta_list, (file.exists)))){
      #
      #
      # }else{
      #       print("File dn2001.file or dn2007.dta does not exist.
      #       Consider using InputData function to copy correct files ?InputData")
      # }


      ### select columns

      geo_dta <- mapply(function(x, y) x %>% dplyr::mutate(svyear = y),
                         dn_dta,
                         c(2001, 2007), SIMPLIFY = F)

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
