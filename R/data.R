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


#' @title Firm 2007 Skill Intensity
#' @description Firm skill intensity measures in 2007, measured by labor composition at the end of 2007
#' @format A data frame with 155771 rows and 15 variables:
#' \describe{
#'   \item{\code{tinh}}{character COLUMN_DESCRIPTION}
#'   \item{\code{macs}}{double COLUMN_DESCRIPTION}
#'   \item{\code{madn}}{double COLUMN_DESCRIPTION}
#'   \item{\code{ma_thue}}{character COLUMN_DESCRIPTION}
#'   \item{\code{endyear_L}}{double Total labor}
#'   \item{\code{PhD}}{double COLUMN_DESCRIPTION}
#'   \item{\code{Masters}}{double COLUMN_DESCRIPTION}
#'   \item{\code{Uni}}{double COLUMN_DESCRIPTION}
#'   \item{\code{College}}{double COLUMN_DESCRIPTION}
#'   \item{\code{Pro}}{double Professional level}
#'   \item{\code{Lterm_voc}}{double Long-term vocational training}
#'   \item{\code{Sterm_voc}}{double Short-term vocational training}
#'   \item{\code{untrained}}{double Untrained profession}
#'   \item{\code{wage_bill}}{double Compensation for employees including wages, bonues, social security, other compensation out of production costs}
#'   \item{\code{insu_pension}}{double Contributions to insurance and pension, health, trade-union}
#'}
#' @source \url{https://www.gso.gov.vn/en/enterprises/}
"skill_07_dta"
