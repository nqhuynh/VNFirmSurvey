
#' @title Get wage bill data for firms 2001 and 2007
#' @description Input a list of enterprise dn files and
#' get wage bill data for firms between 2001 and 2007
#' @param dta_list raw data list dn from GSO
#' @param store_dir If provided a store_dir, then the output wage data frame will be stored there.
#' Otherwise, output the cleaned data frame.
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with 212322 rows and 8 variables
#' @details The list of data dn has to be ordered correctly, first 2001 then 2007.
#' Firm compensation for employees, already removed missing values for total_L, wage_bill, and ave_wage, and firms with zero employees.
#' A data frame with 212322 rows and 8 variables
#' @rdname getWage
#' @import data.table
#' @export

getWage <- function(dta_list, store_dir){

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

      wage_dta <- mapply(function(x, y) x %>% dplyr::mutate(svyear = y),
                         dn_dta,
                         c(2001, 2007), SIMPLIFY = F)

      wage_dta <- lapply(wage_dta, function(x)  setDT(x)[, .( svyear,
                                                        tinh, macs, madn,   ma_thue,
                                                        total_L =  ld13,
                                                        wage_bill = tn1,
                                                        ave_wage = tn1/ld13)])

      wage_dta <- data.table::rbindlist(wage_dta)

      DataExplorer::update_columns(wage_dta, c("tinh", "madn", "macs", "ma_thue"), as.factor)

      ### Remove NAs rows in total_L, wage_bill, and ave_wage
      wage_dta <- stats::na.omit(wage_dta)

      ### Remove firms with zero total labor, only in svyear 2001
      wage_dta <- wage_dta[total_L > 0]

      ## Label variables
      var_label(wage_dta) <- list(svyear = "Year",
                                  tinh = "Province",
                                  macs = "Firm ID",
                                  madn = "Another firm ID?",
                                  ma_thue = "Tax ID",
                                  total_L = "Total number of employees at the end of the year",
                                  wage_bill = "Compensation for employees including wages,
                                             salaries, bonus, social security,
                                                and other compensation out of production costs",
                                  ave_wage = "wage_bill/ total_L")


      if (!missing(store_dir)){

            saveRDS(wage_dta,
                    file = store_dir)

            return(print(paste("Data is stored at "), store_dir))
      }else{

            return(wage_dta)
      }

}
