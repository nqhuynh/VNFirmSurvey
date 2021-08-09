#' @title Firm 2001 Skill Intensity
#' @description Firm skill intensity measures in 2001. Unlike other years, these skill measures are at the headquarter level and include workers up to July 1st 2002.
#' @format A data frame with 56541 rows and 9 variables:
#' \describe{
#'   \item{\code{tinh}}{integer Province of location}
#'   \item{\code{macs}}{integer Plant ID}
#'   \item{\code{madn}}{integer Firm ID}
#'   \item{\code{ma_thue}}{integer Tax ID}
#'   \item{\code{total_L_head}}{double Total labor up to July 1st 2002 at headquarters (person)}
#'   \item{\code{SI_1}}{double (PhD + Masters + Uni + College + Pro_secd + technical)/ total_L_head)}
#'   \item{\code{SI_2}}{double Replace in SI_1 prefessional secondary and technical workers by number of higher skilled workers among technical and professional workers}
#'   \item{\code{SI_3}}{double The same as SI_2 except dropping college (Cao Dang)}
#'   \item{\code{SI_4}}{double The same as SI_3 except dropping high_skill_tec (added in SI_2)}
#'}
#' @source \url{https://www.gso.gov.vn/en/enterprises/}
"skill_01_dta"
