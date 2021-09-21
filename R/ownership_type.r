
#' @title Firm harmonized-ownership type 2001-2019
#' @description Input a list of enterprise dn files and
#' get location data for firms 2001, 2004 and 2007
#' @param geo_dta geographic data 2001-2019
#' @return Either a stored data in store_dir, or a cleaned data frame.  A data frame with  rows and  variables
#' @details The list of data dn has to be ordered correctly to match with the years vector of survey years.
#' The harmonization follows Mccaig et al (2020) Appendix Table 4: Ownership types by year.
#' @rdname ownership
#' @import data.table
#' @export

ownership <- function(geo_dta){

      #owner_data <- readRDS("/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/cleaned_data/geo_dta.rds")

      owner_data <-    harmonize_ownership(geo_dta)

      owner_data <-  owner_data[, .( svyear, firm_id,
                                     ma_thue,  unique_tax_id,
                                     xa,
                                     huyen,
                                     tinh,
                                     sector,
                                     ownership,
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
                                       ))]

      #DataExplorer::profile_missing(owner_data)

      return(owner_data)


}




harmonize_ownership <- function(dta){
   # dta[svyear == 2001, ownership := fcase(
   #       lhdn == 1, "Central SOE",
   #       lhdn == 2, "Local SOE",
   #       lhdn == 3, "Collective",
   #       lhdn == 4, "Private enterprise",
   #       lhdn == 5, "Partnership company",
   #       lhdn == 6, "State LLC",
   #       lhdn == 7, "Private LLC",
   #       #lhdn == 8, "State LLC",
   #       lhdn == 9, "Private LLC",
   #       #lhdn == 10, "State LLC",
   #       lhdn == 11, "JSC without state capital",
   #       lhdn == 12, "100% foreign",
   #       lhdn == 13, "Foreign with state partner",
   #       lhdn == 14, "Foreign with other partner")]

   dta[svyear == 2001 | svyear == 2002, ownership := fcase(
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

   dta[(svyear > 2002 & svyear <= 2004), ownership := fcase(
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

   dta[(svyear > 2004 & svyear <= 2011), ownership := fcase(
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
            lhdn == 11, "JSC with state capital<50%", # In 2011, the survey asks whether the government intervenes
            lhdn == 12, "100% foreign",
            lhdn == 13, "Foreign with state partner",
            lhdn == 14, "Foreign with other partner"
         )]

   dta[(svyear >= 2012 & svyear <= 2019), ownership := fcase(
            lhdn == 1, "Central SOE",
            lhdn == 2, "Local SOE",
            lhdn == 3, "JSC or Private LLC with state capital>50%",
            lhdn == 4, "Central SOE",
            lhdn == 5, "Collective",
            lhdn == 6, "Private enterprise",
            lhdn == 7, "Partnership company",
            lhdn == 8,  "Private LLC",
            lhdn == 9, "JSC without state capital",
            lhdn == 10, "JSC with state capital<50%", #  In 2011-2015 the survey asks whether the government intervenes
            lhdn == 11, "100% foreign",
            lhdn == 12, "Foreign with state partner",
            lhdn == 13, "Foreign with other partner"
         )]

   return(dta)
}

#
#
# if (svyear == 2001)
# { #ft_von
#    dta[, ownership := fcase(
#       lhdn == 1, "Central SOE",
#       lhdn == 2, "Local SOE",
#       lhdn == 3, "Collective",
#       lhdn == 4, "Private enterprise",
#       lhdn == 5, "Partnership company",
#       lhdn == 6, "State LLC",
#       lhdn == 7, "Private LLC",
#       #lhdn == 8, "",
#       lhdn == 9, "Private LLC",
#       #lhdn == 10, "State LLC",
#       lhdn == 11, "JSC without state capital",
#       lhdn == 12, "100% foreign",
#       lhdn == 13, "Foreign with state partner",
#       lhdn == 14, "Foreign with other partner"
#    )]
# }else if (svyear == 2002)
# {
#    dta[, ownership := fcase(
#       lhdn == 1, "Central SOE",
#       lhdn == 2, "Local SOE",
#       lhdn == 3, "Collective",
#       lhdn == 4, "Private enterprise",
#       lhdn == 5, "Partnership company",
#       lhdn == 6, "State LLC",
#       lhdn == 7, "State LLC",
#       lhdn == 8, "Private LLC",
#       lhdn == 9, "JSC or Private LLC with state capital>50%",
#       lhdn == 10, "JSC with state capital<50%",
#       lhdn == 11, "JSC without state capital",
#       lhdn == 12, "100% foreign",
#       lhdn == 13, "Foreign with state partner",
#       lhdn == 14, "Foreign with other partner"
#    )]
# }else if (svyear == 2003 | svyear == 2004)
# {
#    dta[, ownership := fcase(
#       lhdn == 1, "Central SOE",
#       lhdn == 2, "Local SOE",
#       lhdn == 3, "State LLC",
#       lhdn == 4, "State LLC",
#       lhdn == 5, "JSC or Private LLC with state capital>50%",
#       lhdn == 6, "Collective",
#       lhdn == 7, "Private enterprise",
#       lhdn == 8, "Partnership company",
#       lhdn == 9, "Private LLC",
#       lhdn == 10, "JSC without state capital",
#       lhdn == 11, "JSC with state capital<50%",
#       lhdn == 12, "100% foreign",
#       lhdn == 13, "Foreign with state partner",
#       lhdn == 14, "Foreign with other partner"
#    )]}else if (svyear > 2004 & svyear <= 2011)
#    {
#       dta[, ownership := fcase(
#          lhdn == 1, "Central SOE",
#          lhdn == 2, "Local SOE",
#          lhdn == 3, "State LLC",
#          lhdn == 4, "State LLC",
#          lhdn == 5, "JSC or Private LLC with state capital>50%",
#          lhdn == 6, "Collective",
#          lhdn == 7, "Private enterprise",
#          lhdn == 8, "Partnership company",
#          lhdn == 9, "Private LLC",
#          lhdn == 10, "JSC without state capital",
#          lhdn == 11, "JSC with state capital<50%", # In 2011, the survey asks whether the government intervenes
#          lhdn == 12, "100% foreign",
#          lhdn == 13, "Foreign with state partner",
#          lhdn == 14, "Foreign with other partner"
#       )]
#    }else if (svyear >= 2012 & svyear <= 2019)
#    {
#       dta[, ownership := fcase(
#          lhdn == 1, "Central SOE",
#          lhdn == 2, "Local SOE",
#          lhdn == 3, "JSC or Private LLC with state capital>50%",
#          lhdn == 4, "Central SOE",
#          lhdn == 5, "Collective",
#          lhdn == 6, "Private enterprise",
#          lhdn == 7, "Partnership company",
#          lhdn == 8,  "Private LLC",
#          lhdn == 9, "JSC without state capital",
#          lhdn == 10, "JSC with state capital<50%", #  In 2011-2015 the survey asks whether the government intervenes
#          lhdn == 11, "100% foreign",
#          lhdn == 12, "Foreign with state partner",
#          lhdn == 13, "Foreign with other partner"
#       )]
#    }
