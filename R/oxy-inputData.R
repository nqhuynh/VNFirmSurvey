#' @title Copy Raw Firm Data
#' @description Get links to Firm data folders and copy to package
#' @param dta_dir A path to local location of raw data at year level
#' @param store_dir Path to store data location
#' @return A copied version of the folder in inst/extdata
#' @examples InputData("/Volumes/GoogleDrive/My Drive/econ_datasets/Vietnam_VES/Data/Stata_2007_2009/Stata_2007")
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname InputData
#' @export
InputData <- function(dta_dir,
                      store_dir = here::here("inst", "extdata")) {

      file.copy(from = dta_dir,
                to = store_dir,
                recursive = T,
                overwrite = F)

}
