
#' @title Clean and create skill intensity variables 2001 and 2007
#' @description Get firm characteristics including skill composition
#' and total labot and output firm skill intensity measures
#' @param dta_list list of raw skill composition data with tinh, madn, macs, ma_thue, svyear variables
#' @return Cleaned data frame with skill intensity measures across years
#' @details In 2001, total labor is measured at the Number of workers at HEADQUARTER,
#' while other years are total labor at the entire enterprise
#' @import data.table
#' @rdname clean_skill
#' @export
clean_skill <- function(dta_list){
      ## Only get years that have skill 2001, 2007
      dta_list <- list(dn2001.file, dn2007.file)
      ### read the Stata files
      dn_dta <- lapply(dta_list, haven::read_dta)
      dn_dta <- lapply(dn_dta, data.table::setDT)

      ### select variables
      skill_dta <- mapply(SelectColumnsSkill,
                          c(2001, 2007),
                          dn_dta,
                          SIMPLIFY = F)

      ### Deal with missing variables

      # Apart from missing data for total number of employees,
      # I interpret missing data for other skill variables as having zero observations.
      # I also drop firms with missing total_L data

      skill_dta <- lapply(skill_dta,
             function(x) { DataExplorer::update_columns(x, ind = c("tinh", "madn", "macs", "ma_thue"),
                                                        what = as.factor);
                DataExplorer::set_missing(x, 0L,exclude = "total_L");
                return(x)})

      skill_dta <- stats::na.omit(skill_dta)


      ### Remove firms with zero total_L (only 2)
      skill_dta <-  lapply(skill_dta, "[", total_L > 0)

      ### Construct Skill Intensity
      skill_dta <- lapply(skill_dta, ConstructSkillIntensity)

      skill_dta <- data.table::rbindlist(skill_dta)


      return(skill_dta)
}


SelectColumnsSkill <- function(svyear, dta){
      if (svyear == 2001){

         dta <- (dta)[, .(svyear,  tinh,  macs, madn, ma_thue,
                          total_L = ldc11, # Number of workers at HEADQUARTER
                          PhD = ldc21,
                                                Masters = ldc31,
                                                Uni = ldc41,
                                                College = ldc51,
                                                #Pro_secd = ldc61,
                                                #technical = ldc71,
                                                high_skill_tec = ldc81)]

      }else{
         dta <- (dta)[, .(svyear,
                                                tinh,
                                                macs,
                                                madn,
                                                ma_thue,
                                                #endyear_L = ldct11,
                                                total_L = ld13,
                                                PhD = ldct91,
                                                Masters = ldct101,
                                                Uni = ldct111,
                                                College = ldct121,
                                                Pro = ldct131,
                          high_skill_tec = (ldct131 + ldct141),
                                                Lterm_voc = ldct141,
                                                Sterm_voc = ldct151)]
      }
   return(dta)
}

ConstructSkillIntensity <- function(dta){
   ### Construct skill intensity (SI) measures


   dta[, SI_1 := ((PhD + Masters + Uni + College + high_skill_tec)/ total_L)]

   dta[, SI_2 := ((PhD + Masters + Uni + high_skill_tec)/ total_L)]

   dta[, SI_3 := ((PhD + Masters + Uni)/ total_L)]

   dta <- dta[, .(svyear, tinh, macs, madn, ma_thue,
                              total_L,
                              SI_1, SI_2, SI_3)]
   return(dta)

}
