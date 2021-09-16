

#' @title Firm geographic location and sectors 2000-2011, Not harmonized
#' @description Input a list of enterprise dn files and
#' get location data for firms 2000-2011
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @param years A vector of survey years that correspond to the raw data list dn from GSO dta_list
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly to match with the years vector of survey years.
#' @rdname getLocation
#' @import data.table
#' @export

getLocation <- function(dta_list,
                        years,
                        store_dir){

      ### read the Stata files
      dn_dta <- lapply(dta_list, function(x) haven::read_dta(x, encoding = "latin1"))
      dn_dta <- lapply(dn_dta, setDT)

      ### select columns

      geo_dta <- mapply(function(x, y) x %>% dplyr::mutate(svyear = y),
                         dn_dta,
                        years, SIMPLIFY = F)

      geo_dta <- lapply(geo_dta, function(x) harmonize_sector(x,
                                                crosswalk = here::here("inst", "extdata",
                                                                 "vsic_2007_to_1993.xlsx")))

      geo_dta <- lapply(geo_dta, function(x)    (x)[, .( svyear,
                                                              macs, madn,
                                                              ma_thue,
                                                              #ma_thue2,
                                                              xa,
                                                              huyen,
                                                              tinh,
                                                            sector = fcase(
                                                               svyear < 2007, nganh_kd,
                                                               svyear >= 2007, vsis_93) )])

      geo_dta <- data.table::rbindlist(geo_dta)

      DataExplorer::update_columns(geo_dta,
                                   c( "madn", "macs", "ma_thue",
                                      "xa", "huyen", "tinh",
                                     "sector"), as.factor)

      DataExplorer::profile_missing(geo_dta)

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



harmonize_sector <- function(dta,
                             crosswalk){

      crosswalk <- readxl::read_xlsx(crosswalk)
      crosswalk <- setDT(crosswalk)[, .(vsis_07 = nganh_kd,
                                        vsis_93 = nganh_cu)]
      dta <- merge(dta, crosswalk,
            all.x = TRUE,
            by.x = "nganh_kd",
            by.y = "vsis_07")
      return(dta)
}


## Create harmonized products
# get 2007-2010 data
# sector_crosswalk<- rbindlist(list(geo_dta[[2]][, .(svyear, tennganhkd, nganh_kd, nganh_cu)],
#                                   geo_dta[[3]][, .(svyear, tennganhkd, nganh_kd, nganh_cu)],
#                                   #geo_dta[[4]][, .(svyear, tennganhkd, nganh_kd, nganh_cu)],
#                                   geo_dta[[5]][, .(svyear, tennganhkd, nganh_kd, nganh_cu)]))[!is.na(nganh_cu) ][order(-nganh_cu)]
#
# temp <- sector_crosswalk[!duplicated(nganh_kd) ][order(-nganh_kd)]
# temp_2 <- sector_crosswalk[!duplicated(nganh_cu) ][order(-nganh_cu)]
#
# writexl::write_xlsx(temp, here("inst", "extdata", "vsic_2007_to_1993.xlsx"))
# writexl::write_xlsx(temp_2, here("inst", "extdata", "vsic_1993_to_2007.xlsx"))
