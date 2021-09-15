
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

      ### read the Stata files
      dn_dta <- lapply(dta_list, haven::read_dta)
      dn_dta <- lapply(dn_dta, setDT)

      ### select columns

      owner_data <- mapply(function(x, y) x[, svyear := y],
                        dn_dta,
                        years, SIMPLIFY = F)

      owner_data <- mapply(harmonize_ownership,
                           dn_dta,
                           years,
                           SIMPLIFY = F)

      owner_data <-
         lapply(owner_data,
                function(x)
                   (x)[, .( svyear, macs, madn,
                            ma_thue, ownership,
                            simple_ownership = fcase(
                               (ownership == "Central SOE" |
                                  ownership == "Local SOE" |
                                   ownership == "State LLC" |
                                  ownership == "JSC or Private LLC with state capital>50%"), "state-owned",
                               (ownership == "Collective" |
                                   ownership == "Private enterprise" |
                                   ownership == "Partnership company" |
                                   ownership == "Private LLC" |
                                   ownership == "JSC with state capital<50%" |
                                   ownership == "JSC without state capital"), "private",
                               (ownership == "100% foreign" |
                                   ownership == "Foreign with state partner"|
                                   ownership == "Foreign with other partner"), "foreign"
                                       ))])

      owner_data <- data.table::rbindlist(owner_data)

      DataExplorer::update_columns(owner_data,
                                   c( "madn", "macs", "ma_thue"), as.factor)

      #DataExplorer::profile_missing(owner_data)

      ## Label variables


      if (!missing(store_dir)){

            saveRDS(owner_data,
                    file = store_dir)

            return(print(paste("Data is stored at "), store_dir))
      }else{

            return(owner_data)
      }

}




harmonize_ownership <- function(dta, svyear){
   if (svyear == 2001)
   { #ft_von
      dta[, ownership := fcase(
         lhdn == 1, "Central SOE",
         lhdn == 2, "Local SOE",
         lhdn == 3, "Collective",
         lhdn == 4, "Private enterprise",
         lhdn == 5, "Partnership company",
         lhdn == 6, "State LLC",
         lhdn == 7, "Private LLC",
         #lhdn == 8, "",
         lhdn == 9, "Private LLC",
         #lhdn == 10, "State LLC",
         lhdn == 11, "JSC without state capital",
         lhdn == 12, "100% foreign",
         lhdn == 13, "Foreign with state partner",
         lhdn == 14, "Foreign with other partner"
      )]
   }else if (svyear == 2002)
   {
      dta[, ownership := fcase(
         lhdn == 1, "Central SOE",
         lhdn == 2, "Local SOE",
         lhdn == 3, "Collective",
         lhdn == 4, "Private enterprise",
         lhdn == 5, "Partnership company",
         lhdn == 6, "State LLC",
         lhdn == 7, "State LLC",
         lhdn == 8, "Private LLC",
         lhdn == 9, "JSC or Private LLC with state capital>50%",
         lhdn == 10, "JSC with state capital<50%",
         lhdn == 11, "JSC without state capital",
         lhdn == 12, "100% foreign",
         lhdn == 13, "Foreign with state partner",
         lhdn == 14, "Foreign with other partner"
      )]
   }else if (svyear == 2003 | svyear == 2004)
   {
      dta[, ownership := fcase(
         lhdn == 1, "Central SOE",
         lhdn == 2, "Local SOE",
         lhdn == 3, "State LLC",
         lhdn == 4, "State LLC",
         lhdn == 5, "JSC or Private LLC with state capital>50%",
         lhdn == 6, "Collective",
         lhdn == 7, "Private enterprise",
         lhdn == 8, "Partnership company",
         lhdn == 9, "Private LLC",
         lhdn == 10, "JSC without state capital",
         lhdn == 11, "JSC with state capital<50%",
         lhdn == 12, "100% foreign",
         lhdn == 13, "Foreign with state partner",
         lhdn == 14, "Foreign with other partner"
      )]}else if (svyear > 2004 & svyear < 2011)
      {
         dta[, ownership := fcase(
            lhdn == 1, "Central SOE",
            lhdn == 2, "Local SOE",
            lhdn == 3, "State LLC",
            lhdn == 4, "State LLC",
            lhdn == 5, "JSC or Private LLC with state capital>50%",
            lhdn == 6, "Collective",
            lhdn == 7, "Private enterprise",
            lhdn == 8, "Partnership company",
            lhdn == 9, "Private LLC",
            lhdn == 10, "JSC without state capital",
            lhdn == 11, "JSC with state capital<50%",
            lhdn == 12, "100% foreign",
            lhdn == 13, "Foreign with state partner",
            lhdn == 14, "Foreign with other partner"
         )]
      }
   return(dta)
}
