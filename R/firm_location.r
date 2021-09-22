

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
                             sector = nganh_kd,
                             lhdn)]
         }else{
            dta <-  dta[, .( svyear = svyear,
                             #macs, madn,
                             unique_tax_id = paste0(tinh, ma_thue),
                             ma_thue,
                             xa,
                             huyen,
                             tinh,
                             sector = nganh_kd,
                             lhdn)]
         }
         return(dta)
      }

      geo_dta <- mapply(select_cols,
                        dn_dta,
                        years,
                        SIMPLIFY = F)

      geo_dta <- data.table::rbindlist(geo_dta, fill = T)

      DataExplorer::update_columns(geo_dta,
                                   c( "madn", "macs", "ma_thue"), as.factor)

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


harmonize_district <- function(geo_dta,
                               district_codes){

   ## Using 2015 as the base year for district codes, this is as close to 2009 census map as possible
   district <- district_codes[!is.na(district_2015),
                  .(district_2001 = factor(district_2001),
                    province_2001 = factor(province_2001),
                    district_2004 = factor(district_2004),
                    province_2004 = factor(province_2004),
                    district_2005 = case.(district_2005 >= 10 & district_2005 < 100, paste0("0", district_2005),
                                          district_2005 < 10, paste0("00", district_2005),
                                          district_2005 >= 100, factor(district_2005)),
                    province_2005 = case.(province_2005 >= 10, factor(province_2005),
                                          province_2005 < 10, paste0("0", province_2005)),
                    district_2007 = case.(district_2007 >= 10 & district_2007 < 100, paste0("0", district_2007),
                                          district_2007 < 10, paste0("00", district_2007),
                                          district_2007 >= 100, factor(district_2007)),
                    province_2007 = case.(province_2007 >= 10, factor(province_2007),
                                          province_2007 < 10, paste0("0", province_2007)),
                    district_2010 = case.(district_2010 >= 10 & district_2010 < 100, paste0("0", district_2010),
                                          district_2010 < 10, paste0("00", district_2010),
                                          district_2010 >= 100, factor(district_2010)),
                    province_2010 = case.(province_2010 >= 10, factor(province_2010),
                                          province_2010 < 10, paste0("0", province_2010)),
                    district_2015  = case.(district_2015 >= 10 & district_2015 < 100, paste0("0", district_2015),
                                        district_2015 < 10, paste0("00", district_2015),
                                        district_2015 >= 100, factor(district_2015)),
                    province_2015 = case.(province_2015 >= 10, factor(province_2015),
                                           province_2015 < 10, paste0("0", province_2015)),
                    districtName_2020)]

   dat_list <- list(geo_dta[svyear < 2003],
                    geo_dta[svyear == 2003],
                    geo_dta[svyear > 2003 & svyear < 2007],
                    geo_dta[svyear == 2007],
                    geo_dta[svyear >=  2008 & svyear <= 2018])

   district_list <- list(district[, .(huyen = district_2001, tinh = province_2001,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2004, tinh = province_2004,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2005, tinh = province_2005,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2007, tinh = province_2007,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2015, tinh = province_2015,
                                      district_2015, province_2015)])

   result <- mapply(function(x, y)  {merge(x, y,
                                           all.x =  T,
                                           by = c("huyen", "tinh"),
                                           #by.y = c("district_2015", "province_2015"),
                                           allow.cartesian = T)},
                    dat_list,
                    district_list,
                    SIMPLIFY = F)

   result <- rbindlist(result)

   return(result)
}


#
# harmonize_sector <- function(dta,
#                              crosswalk){
#
#       #crosswalk <- readxl::read_xlsx(crosswalk)
#       crosswalk <- setDT(crosswalk)[, .(vsis_07 = factor(nganh_kd),
#                                         vsis_93 = factor(nganh_cu))]
#       dta <- merge(dta[, nganh_kd := factor(nganh_kd)], crosswalk,
#             all.x = TRUE,
#             by.x = "nganh_kd",
#             by.y = "vsis_07")
#       return(dta)
# }

#
#
## Harmonize provinces
# province_codes <- district_codes[!duplicated(province_2005) & !is.na(province_2005),
#                                  .(province_2001 = factor(province_2001),
#                                    #provinceName_2001,
#                                    province_2004 = factor(province_2004), ## Capture changes in 2003
#                                    #provinceName_2004,
#                                    province_2005 = case.(province_2005 >= 10, factor(province_2005),
#                                                          province_2005 < 10, paste0("0", province_2005)),  ## big changes in 2004
#                                    #provinceName_2005,
#                                    province_2020)  ] ## Finally, Ha Tay
#
# merge(geo_dta[svyear <= 2002, .N, by = tinh],
#       district_2005,
#       by.x = "tinh",
#       by.y = "province_2001")

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
