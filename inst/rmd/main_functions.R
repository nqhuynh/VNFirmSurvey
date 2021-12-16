

ColSelect <- function(dta){
      setDT(dta)

      dta <-  dta[, .(year,
                      svyear = year,
                      madn,
                      taxcode,
                      province2003,
                      province2004,
                      district,
                      startyear,
                      empend,
                      wages,
                      kend,
                      revenue,
                      valueadded,
                      dexport,
                      dimport,
                      dexport2,
                      dimport2,
                      exports,
                      imports,
                      country,
                      countryname,
                      ward,
                      wardnewconsistent,
                      dist1999consistent,
                      zone,
                      zonetype,
                      lessmeddistport,
                      vsic1993,
                      vsic1993_vsic2007,
                      vsic2007description
      )]

      return(dta)
}


SaveEntryDta <- function(dta, base_year, years){

      dta <- EntryExit(geo_dta = dta,
                       base_year = base_year,
                       years = years)

      return(dta)
}


BranchData <- function(year_length){


      dta_list <- list(here("inst", "extdata", "Data_DS_Updated", "ds2000.dta"),
                         here("inst", "extdata", "Data_DS_Updated", "ds2001.dta"),
                         here("inst", "extdata", "Data_DS_Updated", "ds2002.dta"),
                         here("inst", "extdata", "Data_DS_Updated", "ds2003.dta"),
                         here("inst", "extdata", "Data_DS_Updated", "ds2004.dta"),
                         here("inst", "extdata", "Data_DS_Updated", "ds2005.dta"),
                         here("inst", "extdata", "Data_DS_Updated", "ds2006.dta"),
                         here("inst", "extdata",  "Stata_2007", "ds2007.dta"),
                         here("inst", "extdata",  "Stata_2008", "ds2008.dta"),
                         here("inst", "extdata",  "Stata_2009", "ds2009.dta"),
                         here("inst", "extdata",  "Stata_2010", "ds2010.dta"),
                         here("inst", "extdata",  "Stata_2011", "cs2011.dta"),
                         here("inst", "extdata",  "Stata_2012", "ds2012.dta"),
                         here("inst", "extdata",  "Stata_2013", "ds2013.dta"),
                         here("inst", "extdata",  "Stata_2014", "ds2014.dta")
      )

      #geo_dta <- VNFirmSurvey::ownership(geo_dta)



      dta <- VNFirmSurvey::plant(dta_list = dta_list,
                                 years = year_length)

      return(dta)

}

MergeBranchFirmID <- function(firm_dta, branch_dta){

      merged_dta <- merge(firm_dta,
                          branch_dta[, .(plant_num = .N), by = .(madn, svyear)],
                          by = c("madn", "svyear"),
                          all.x = T)

      merged_dta[is.na(plant_num), plant_num := 0]
#
#       merged_dta[, .N, by = .(plant_num, svyear)][plant_num > 0]
#
#       sum_dta <- merged_dta[, .(plant_num_0_1 = (plant_num < 2) , svyear, simple_ownership)][!is.na(simple_ownership),
#                                                                                              .N,
#                                                                                              by = .(svyear, simple_ownership, plant_num_0_1)
#       ]
#
#       num_plant <- datasummary(factor(svyear) * simple_ownership * plant_num_0_1 ~ N + Percent(),
#                                data = sum_dta)
#
#       g_dta <- sum_dta[svyear < 2015, percent := prop.table(N)*100, .(svyear, simple_ownership)][plant_num_0_1 == F][order(svyear)]

      fwrite(x = merged_dta[sample(nrow(merged_dta), 100000),],
             file = here("inst", "tmp", "plant_firm_dta.csv"))

      return(merged_dta)
}

# library(ggrepel)
#
# g <- ggplot(data= g_dta, aes(x = factor(svyear), y = percent, group = simple_ownership)) +
#       geom_line(aes(color=simple_ownership))+
#       geom_point(aes(color=simple_ownership)) +
#       #geom_text(aes(label = percent), hjust=0.7, vjust=-0.5, size = 4) +
#       # scale_y_continuous(trans='log2',
#       #                    limits = c(NA,NA)) +
#       labs(x = "Year",
#            y = "",
#            title = "Percentage of firms with more than 1 branch, by ownership",
#            caption = "Source: Vietnam Annual Enterprise Surveys 2001-2014") +
#       theme_minimal() +
#       theme(#axis.line.y = element_blank(),
#             #axis.text.y = element_blank(),
#             #axis.ticks.y = element_blank(),
#             legend.title = element_blank(),
#             legend.position = "none") +
#
#       geom_text_repel(aes(label = simple_ownership),
#                       data = g_dta[svyear == 2014],
#                       #color = "red",
#                       hjust = 1,
#                       size = 4,
#                       nudge_x = 0) +
#       scale_color_brewer(palette = "Dark2")
#
# ggsave(plot = g, path = "/Users/nghiemhuynh/Documents/papers/TradeSOE/output",
#        filename = "plant_share_by_ownership.png")






PlantNumTab <- function(dta){

      num_firm <- dta[, .N, by = .(svyear)][order(svyear)]

      g <- ggplot(num_firm,
                  aes(x = factor(svyear),
                      y = N,
                      group = 1)) +
            geom_point() +
            geom_line()+
            labs( title = "Number of firms over years",
                  x = "Year",
                  y = "")


      return(num_firm)

}






AggEntryShareYear <- function(entry_graph_dta){



      graph_dta <- entry_graph_dta[, .(avg = mean(entrant_share, na.rm = T)), by = .(svyear = (svyear))]

      g <- ggplot(graph_dta,
                  aes(x =  factor(svyear),  y = avg)) +
            geom_line(group = 1, color= "steelblue", size = 1) +
            geom_point(alpha = 0.3) +
            labs(title = "Entrant share (%)",
                 subtitle = "Fraction of entrants among all surveyed firms in a year",
                 caption = "Source: Annual Firm Survey 2001-2018",
                 x = "Year",
                 y = "")+
            theme_minimal()


      return(g)
}
