

#' @title Firm geographic location and sectors 2000-2018, harmonized district codes
#' @description Input a list of enterprise dn files and
#' get location data for firms 2000-2018
#' @param dta_list raw data list dn from GSO
#' @param district_codes If provided a district_codes file path, then the output data has district codes harmonized according to
#' the 2015 district codes.
#' @param years A vector of survey years that correspond to the raw data list dn from GSO dta_list
#' @param crosswalk_07_to_93 If provided a crosswalk_07_to_93 file path, then the output data has sector codes harmonized according to
#' the 1993 VSIC codes.
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly to match with the years vector of survey years.
#' @rdname getLocation
#' @import data.table tidytable
#' @export

getLocation <- function(dta_list,
                        years,
                        district_codes,
                        crosswalk_07_to_93){

      ### read the Stata files
      dn_dta <- lapply(dta_list, function(x) haven::read_dta(x, encoding = "latin1"))
      dn_dta <- lapply(dn_dta, setDT)


      ### select columns
      select_cols <- function(dta, year){
         final_dta <-  dta[, .( svyear = year,
                                # macs, madn,
                                # capso,
                                ma_thue,
                                xa,
                                huyen,
                                tinh,
                                sector = nganh_kd,
                                lhdn,
                                endyear_L = ld11,
                                # wage_bill = tn11,
                                revenue = kqkd1,
                                total_asset = ts12
         )]
         if (year < 2016){

            final_dta[, `:=` (macs = dta$macs,
                              madn = dta$madn,
                              capso = dta$capso)]
         }

         if (year == 2009){
            final_dta[, wage_bill :=  dta$tn11]

         }else{
            final_dta[, wage_bill :=  dta$tn1]

         }

         return(final_dta)
      }

      geo_dta <- mapply(select_cols,
                        dn_dta,
                        years,
                        SIMPLIFY = F)

      geo_dta <- data.table::rbindlist(geo_dta, fill = T)

      ## Label variables
      var_label(geo_dta) <- list(svyear = "Year",
                                  tinh = "Province",
                                  macs = "Firm ID",
                                  madn = "Another firm ID?",
                                  ma_thue = "Tax ID",
                                  xa = "commune",
                                  huyen = "district",
                                 revenue = "Total revenue and other income (no sales tax) (kqkd1)",
                                  total_asset = "Total assets at the end of the year ts12")


      if (!missing(district_codes) & !missing(crosswalk_07_to_93)){

         geo_dta <- harmonize_sector(dta = geo_dta,
                                     crosswalk_07_to_93 = crosswalk_07_to_93)

         geo_dta <- harmonize_district(geo_dta = geo_dta,
                                            district_codes = district_codes)

         geo_dta[svyear < 2016,
                      firm_id := paste0(province_2015, madn)]

         geo_dta[, unique_tax_id := paste0(tinh, ma_thue)]

         return(geo_dta)

      }else if (!missing(district_codes)){
         geo_dta <- harmonize_district(geo_dta = geo_dta,
                                       district_codes = district_codes)

         geo_dta[svyear < 2016,
                 firm_id := paste0(province_2015, madn)]

         geo_dta[, unique_tax_id := paste0(tinh, ma_thue)]

         return(district_dta)

      }else if (missing(district_codes)){

         geo_dta <- harmonize_sector(dta = geo_dta,
                                     crosswalk_07_to_93 = crosswalk_07_to_93)


         return(geo_dta)

      }else{

         return(geo_dta)

      }


}


harmonize_district <- function(geo_dta,
                               district_codes){

   ## Using 2015 as the base year for district codes, this is as close to 2009 census map as possible

   district <- district_codes[!is.na(district_2015),
                  .(district_2001 = as.character(district_2001),
                    province_2001 = as.character(province_2001),
                    district_2003 = as.character(district_2003),
                    province_2003 = as.character(province_2003),
                    district_2004 = as.character(district_2004),
                    province_2004 = as.character(province_2004),
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
                         district[, .(huyen = district_2003, tinh = province_2003,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2005, tinh = province_2005,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2007, tinh = province_2007,
                                      district_2015, province_2015)],
                         district[, .(huyen = district_2015, tinh = province_2015,
                                      district_2015, province_2015)])

   result <- mapply(function(x, y)  {merge(x, y,
                                           #all.x =  T,
                                           by = c("huyen", "tinh"),
                                           #by.y = c("district_2015", "province_2015"),
                                           allow.cartesian = T)},
                    dat_list,
                    district_list,
                    SIMPLIFY = F)

   result <- rbindlist(result)
   return(result)
}

harmonize_sector <- function(dta,
                             crosswalk_07_to_93){
      ## From 2000 to 2007, use 1993 VSIC. From 2007 to 2017, use VSIC 2007.
      ## 2018 use VSIC 2018.
      ## Harmonize by using 1993.

      crosswalk <- fread(crosswalk_07_to_93)
      crosswalk <- setDT(crosswalk)[, .(vsis_07 = as.character(nganh_kd),
                                        vsis_93 = as.character(nganh_cu))]

      dta[ svyear >= 2016,
               sector := ifelse(substr(sector, 0, 1) == "0",
                                substr(sector, 2, nchar(sector)),
                                sector)]

      dta <- merge(dta, crosswalk,
                   all.x = TRUE,
                   by.x = "sector",
                   by.y = "vsis_07")

      dta[, const_sector_93 := case.(svyear < 2006, sector,
                                     svyear >= 2006, vsis_93)]


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
