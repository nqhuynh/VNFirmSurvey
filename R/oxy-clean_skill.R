
#' @title Clean and create skill intensity variables
#' @description Get firm characteristics including skill composition
#' and total labot and output firm skill intensity measures
#' @param dta raw skill composition data with tinh, madn, macs, ma_thue, svyear variables
#' @return Cleaned data frame with skill intensity measures
#' @details DETAILS
#' @rdname clean_skill
#' @export
clean_skill <- function(dta){
      ### Update columns
      DataExplorer::update_columns(dta,
                     c("tinh", "madn", "macs", "ma_thue"),
                     as.factor)

      ### Deal with missing variables

      # Apart from missing data for total number of employees,
      # I interpret missing data for other skill variables as having zero observations.
      # I also drop firms with missing total_L data

      dta <- setDT(dta)

      DataExplorer::set_missing(dta, 0L, exclude = "total_L")

      dta_clean <- stats::na.omit(dta)

      ### Remove firms with zero total_L (only 2)
      dta_clean <- dta_clean[total_L > 0]


      ### Construct skill intensity (SI) measures
      if (dta_clean$svyear[1] > 2006){
            dta_clean[, high_skill_tec := (Pro + Lterm_voc)]
      }

      dta_clean[, SI_1 := ((PhD + Masters + Uni + College + high_skill_tec)/ total_L)]

      dta_clean[, SI_2 := ((PhD + Masters + Uni + high_skill_tec)/ total_L)]

      dta_clean[, SI_3 := ((PhD + Masters + Uni)/ total_L)]

      dta_clean <- dta_clean[, .(svyear, tinh, macs, madn, ma_thue,
                                 total_L,
                                 SI_1, SI_2, SI_3)]

      return(dta_clean)
}

