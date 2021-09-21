

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
                                   c( "madn", "macs", "ma_thue", "tinh"), as.factor)

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


harmonize_district <- function(geo_dta, district_codes){
   district_codes <- fread("/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/harmonized_district_codes.csv")
   mccaig <- fread("/Volumes/GoogleDrive/.shortcut-targets-by-id/1eDcqByikv9SuhOJqc70ZhSWEUTdnXWk_/Sex Ratio VN/other data/VHLSS and enterprise province codes.csv")

   ## Harmonize provinces
   geo_2001 <- geo_dta[svyear == 2003, .N, by = tinh]
   geo_2004 <- geo_dta[svyear == 2004, .N, by = tinh]

   district_codes[, province_2005 := case.(province_2005 >= 10, factor(province_2005),
                                          province_2005 < 10, paste0("0", province_2005))]  ## big changes in 2004]
   province_codes <- district_codes[!duplicated(province_2005) & !is.na(province_2005),
                  .(province_2001 = factor(province_2001),
                    #provinceName_2001,
                    province_2004 = factor(province_2004), ## Capture changes in 2003
                    #provinceName_2004,
                     province_2005 = case.(province_2005 >= 10, factor(province_2005),
                                          province_2005 < 10, paste0("0", province_2005)),  ## big changes in 2004
                    #provinceName_2005,
                     province_2020)  ] ## Finally, Ha Tay

   merge(geo_dta[svyear <= 2002, .N, by = tinh],
         district_2005,
         by.x = "tinh",
         by.y = "province_2001")


   ## Districts
   district <- district_codes[!is.na(district_2005),
                  .(district_2001 = factor(district_2001),
                    province_2001 = factor(province_2001),
                    district_2004 = factor(district_2004),
                    province_2004 = factor(province_2004),
                    district_2005 = factor(district_2005),
                    province_2005 = factor(province_2005),
                    district_2020,
                    districtName_2020)][order(district_2001)]

   geo <- geo_dta[svyear == 2004,
           .N, by = .(huyen, tinh)][order(huyen)]

   result <-merge(district,
         geo,
         all.y =  T,
         by.x = c("district_2005", "province_2005"),
         by.y = c("huyen", "tinh"))[!is.na(district_2005)]

   View(result)
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
