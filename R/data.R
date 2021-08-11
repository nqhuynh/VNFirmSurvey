#' @title Firm 2001 Skill Intensity
#' @description Firm skill intensity measures in 2001. Unlike other years, these skill measures are at the headquarter level and include workers up to July 1st 2002.
#' @format A data frame with 56541 rows and 9 variables:
#' \describe{
#'   \item{\code{svyear}}{double Survey year}
#'   \item{\code{tinh}}{integer Province of location}
#'   \item{\code{macs}}{integer Plant ID}
#'   \item{\code{madn}}{integer Firm ID}
#'   \item{\code{ma_thue}}{integer Tax ID}
#'   \item{\code{total_L}}{double Total labor up to July 1st 2002 at headquarters (person)}
#'   \item{\code{SI_1}}{double (PhD + Masters + Uni + College + high skill technical)/ total_L)}
#'   \item{\code{SI_2}}{double The same as SI_1 except dropping college (Cao Dang)}
#'   \item{\code{SI_3}}{double The same as SI_2 except dropping high_skill_tec}
#'}
#' @source \url{https://www.gso.gov.vn/en/enterprises/}
"skill_01_dta"

#' @title Firm 2007 Skill Intensity
#' @description Firm skill intensity measures in 2007, measured by labor composition at the end of 2007
#' @format A data frame with 155770 rows and 9 variables:
#' \describe{
#'   \item{\code{svyear}}{double Survey year}
#'   \item{\code{tinh}}{integer Province of location}
#'   \item{\code{macs}}{integer Plant ID}
#'   \item{\code{madn}}{integer Firm ID}
#'   \item{\code{ma_thue}}{integer Tax ID}
#'   \item{\code{total_L}}{double Total number of employees at the end of the year}
#'   \item{\code{SI_1}}{double (PhD + Masters + Uni + College + skilled workers)/ total_L) where skilled workers are professional and long term vocationally trained}
#'   \item{\code{SI_2}}{double The same as SI_1 except dropping college (Cao Dang)}
#'   \item{\code{SI_3}}{double The same as SI_2 except dropping high_skill_tec}
#'}
#' @source \url{https://www.gso.gov.vn/en/enterprises/}
"skill_07_dta"

#' @title Wage data
#' @description Firm compensation for employees
#' @format A data frame with 212322 rows and 8 variables:
#' \describe{
#'   \item{\code{tinh}}{character COLUMN_DESCRIPTION}
#'   \item{\code{macs}}{double COLUMN_DESCRIPTION}
#'   \item{\code{madn}}{double COLUMN_DESCRIPTION}
#'   \item{\code{ma_thue}}{character COLUMN_DESCRIPTION}
#'   \item{\code{total_L}}{double Total number of employees at the end of the year}
#'   \item{\code{wage_bill}}{double Compensation for employees including wages, salaries, bonus, social security, and other compensation out of production costs}
#'   \item{\code{ins_pen}}{double Employer's contributions to insurance and pension, health, trade-union}
#'   \item{\code{svyear}}{double survey year}
#'}
#' @source \url{https://www.gso.gov.vn/en/enterprises/}
"wage_dta"
