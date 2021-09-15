
#' @title Firm harmonized-ownership type 2001, 2004, and 2007
#' @description Input a list of enterprise dn files and
#' get location data for firms 2001, 2004 and 2007
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @param years A vector of survey years that correspond to the raw data list dn from GSO dta_list
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly to match with the years vector of survey years.
#' The harmonization follows Mccaig et al (2020) Appendix Table 4: Ownership types by year.
#' @rdname ownership
#' @import data.table
#' @export

ownership <- function(dta_list,
                      years = c(2001, 2004, 2007),
                      store_dir){
      dta_list <- list("/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2000.dta",
                       "/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2001.dta",
                       "/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2002.dta",
                       "/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2003.dta",
                       "/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2004.dta",
                       "/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2005.dta",
                       "/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Data_DS_Updated/ds2006.dta")

      ### read the Stata files
      dn_dta <- lapply(dta_list, function(x)
            haven::read_dta(file = x,
                            encoding = "latin1"))
      dn_dta <- lapply(dn_dta, data.table::setDT)

      ### select columns
      years <- c(2000:2006)
      plant_data <- mapply(function(x, y) x[, svyear := y],
                           dn_dta,
                           years, SIMPLIFY = F)

      plant_data <- mapply(harmonize_plant,
                           plant_data,
                           years,
                           SIMPLIFY = F)

      plant_data <- data.table::rbindlist(plant_data, fill = TRUE)

      DataExplorer::update_columns(plant_data,
                                   c("tinh", "madn", "macs",
                                     "stt", "sector", "branch_tax_id",
                                     "commune", "district",
                                     "branch_province"), as.factor)

      #DataExplorer::profile_missing(plant_data)

      ## Label variables


      if (!missing(store_dir)){

            saveRDS(plant_data,
                    file = store_dir)

            return(print(paste("Data is stored at "), store_dir))
      }else{

            return(plant_data)
      }

}


harmonize_plant <- function(dta, svyear){
      if (svyear == 2000){
            dta <- dta[, .(svyear,
                    tinh,
                    madn,
                    stt,
                    branch_name = tendv,
                    address = dia_diem,
                    sector =  nganh_kd,
                    net_revenue = d_thu,
                    num_employee = lao_dong
                    )]
      } else if (svyear == 2001){
            dta <- dta[, .(svyear,
                    tinh,
                    madn,
                    macs,
                    stt,
                    branch_name = tencn,
                    branch_tax_id = ma_thue,
                    address = dchi,
                    commune = xa,
                    district = huyen,
                    branch_province = tinhcn,
                    sector =  nganh_kd
            )]
      } else if (svyear > 2001 & svyear <= 2003){
            dta <- dta[, .(svyear,
                    tinh,
                    madn,
                    macs,
                    stt,
                    branch_name = tencn,
                    branch_tax_id = ma_thue,
                    address = dchi,
                    #commune = xa,
                    #district = huyen,
                    branch_province = tinhcn,
                    sector =  nganh_kd,
                    num_employee = lao_dong
            )]
      }else if (svyear > 2003 & svyear <= 2006){
            dta <- dta[, .(svyear,
                    tinh,
                    madn,
                    macs,
                    stt,
                    branch_name = tencn,
                    branch_tax_id = ma_thue,
                    address = dchi,
                    #commune = xa,
                    #district = huyen,
                    branch_province = tinhcn,
                    sector =  nganh_kd,
                    num_employee = lao_dong,
                    net_revenue = doanh_thu
            )]
      }
      return(dta)
}

