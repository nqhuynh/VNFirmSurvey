

packages <- c(
      "here",
      "haven",
      "ggplot2",
      "dplyr",
      "tidytable",
      "cowplot",
      "data.table",
      "modelsummary",
      "ipumsr",
      "htmltools",
      "shiny",
      "DT",
      "sf",
      "fixest",
      "RColorBrewer",
      "labelled",
      "kableExtra",
      "knitr",
      "targets",
      "tarchetypes",
      "DataExplorer",
      "VNFirmSurvey"
)



#Change to install = TRUE to install the required packages
#if (!require("pacman")) install.packages("pacman")
pacman::p_load(packages, character.only = TRUE,
               install = F)

