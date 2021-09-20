

#' @title Firm geographic location and sectors 2000-2018, Not harmonized
#' @description Input a list of enterprise dn files and
#' get location data for firms 2000-2018
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @param years A vector of survey years that correspond to the raw data list dn from GSO dta_list
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly to match with the years vector of survey years.
#' @rdname getLocation
#' @import data.table tidytable
#' @export

getLocation <- function(dta_list,
                        years,
                        store_dir){

      ### read the Stata files
      dn_dta <- lapply(dta_list, function(x) haven::read_dta(x, encoding = "latin1"))
      dn_dta <- lapply(dn_dta, setDT)

      ### select columns
      select_cols <- function(dta, svyear){
         if (svyear < 2016){
            dta <-  dta[, .( svyear = svyear,
                             macs, madn,
                             firm_id = paste0(tinh, capso, madn),
                             ma_thue,
                             unique_tax_id = paste0(tinh, ma_thue),
                             xa,
                             huyen,
                             tinh,
                             sector = nganh_kd)]
         }else{
            dta <-  dta[, .( svyear = svyear,
                             #macs, madn,
                             unique_tax_id = paste0(tinh, ma_thue),
                             ma_thue,
                             xa,
                             huyen,
                             tinh,
                             sector = nganh_kd)]
         }
         return(dta)
      }

      geo_dta <- mapply(select_cols,
                        dn_dta,
                        years,
                        SIMPLIFY = F)

      geo_dta <- data.table::rbindlist(geo_dta, fill = T)

      DataExplorer::update_columns(geo_dta,
                                   c( "madn", "macs", "ma_thue",
                                      "xa", "huyen", "tinh"), as.factor)

      #DataExplorer::profile_missing(geo_dta)

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


harmonize_firmID <- function(geo_dta){

   dynamic_dta <- EntryExit(geo_dta,
             base_year = 2015,
             years = c(2016:2017))

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

   dta<- dta[, .(svyear,
                 xa,
                 huyen,
                 tinh,
                 sector,
                 status_2016rel_2015,
                 firm_2015_id,
                 unique_tax_id,
           firm_id = case.(
              svyear < 2016, firm_id,
              svyear >= 2016 &
                 (status_2016rel_2015 == "incumbent" |
                     status_2017rel_2015 == "incumbent" ), firm_2015_id,
              default = unique_tax_id
           ) )]

   return(dta)
}

harmonize_sector <- function(dta,
                             crosswalk){

      crosswalk <- readxl::read_xlsx(crosswalk)
      crosswalk <- setDT(crosswalk)[, .(vsis_07 = factor(nganh_kd),
                                        vsis_93 = factor(nganh_cu))]
      dta <- merge(dta[, nganh_kd := factor(nganh_kd)], crosswalk,
            all.x = TRUE,
            by.x = "nganh_kd",
            by.y = "vsis_07")
      return(dta)
}

#
# geo_dta <- lapply(geo_dta, function(x) harmonize_sector(x,
#                                                         crosswalk = here::here("inst", "extdata",
#                                                                                "vsic_2007_to_1993.xlsx")))


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
