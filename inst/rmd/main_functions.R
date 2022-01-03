

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

      temp <- merge(firm_dta,
                          branch_dta[, .(plant_num = .N), by = .(madn, svyear)],
                          by = c("madn", "svyear"),
                          all.x = T)

      temp[is.na(plant_num), plant_num := 0]

      fwrite(x = temp[sample(nrow(temp), 100000),],
             file = here("inst", "tmp", "plant_firm_dta.csv"))



      return(temp)

}



SingleMutiPlant <- function(dta){


      single_multi_plant <- dta[, .(num_firm = .N,
                                     sales = sum(revenue, na.rm = T)),
                                 by = .(plant_num > 1,
                                        svyear)]

      share_dta <- single_multi_plant[, `:=` (share_num = prop.table(num_firm),
                                          share_sales = prop.table(sales)),
                                      by = svyear]

      graph_dta <- melt(share_dta[plant_num == F, .(share_num,
                                       share_sales,
                                       svyear)],
           id.vars = "svyear")

      g <- ggplot(data = graph_dta[svyear < 2015] ,
                  aes(x = factor(svyear),
                      y = value*100,
                      group = variable)) +
            geom_point(aes(col = variable)) +
            geom_line(aes(col = variable)) +
            labs(title = "Single-plant firms shares",
                 x = "Year",
                 y = "") +
            theme_minimal()

      ggsave(plot = g,
             filename = "single_plant_share.png",
             dpi = 300,
             path = here("inst", "tmp", "figure"))

      mean_plant <- dta[plant_num > 0, .(mean_plant_per_firm = mean(plant_num)),
                         by = svyear][order(svyear)]

      return(list(share_dta, mean_plant))
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

}


EnExitDta <- function(dta, year_list){

      df_id <- c("svyear")

      tmp <- rbindlist(lapply(year_list,
                              function(x)  PairEntryExit(dta = dta,
                                                      yyear = x,
                                                      df_id = df_id)))

      tmp_ind <- rbindlist(lapply(year_list,
                              function(x)  PairEntryExit(dta = dta,
                                                         yyear = x,
                                                         df_id = c(df_id, "vsic1993"))))
      fwrite(tmp,
             file = here("inst", "tmp", "entry_exit_dta.csv"))

      fwrite(tmp_ind,
             file = here("inst", "tmp", "entry_exit_ind_dta.csv"))

      g_dta <- melt(tmp,
                    id.vars = "svyear")

      g <- ggplot(g_dta,
             aes(x = svyear,
                 y = value,
                 group = variable))+
            geom_point(aes(col = variable)) +
            geom_line(aes(col = variable)) +
            labs(x = "Year",
                 y = "") +
            theme(legend.position = "bottom") +
            theme_minimal() +
            scale_color_brewer(palette = "Dark2")

      ggsave(plot = g,
             filename = "entry_exit_g.png",
             path = here("inst", "tmp", "figure"))



      return(tmp)


}


PairEntryExit <- function(dta,
                       yyear,
                       df_id) {

      pre_year <-  yyear-5

      rel_col <- paste0("status_", yyear, "rel_", pre_year)

      year_pair <-  paste(pre_year, yyear, sep = "-")

      entry <- dta[svyear == yyear ,
                   .(num_firm = .N,
                     sales = sum(revenue, na.rm = T)),
                   by = c( df_id,  eval(rel_col))]

      exit <- dta[svyear ==pre_year ,
                   .(num_firm = .N,
                     sales = sum(revenue, na.rm = T)),
                   by = c( df_id,  eval(rel_col))]

      entry_exit_dta  <- rbindlist(list(entry, exit))

      entry_exit_dta[, `:=` (num_shares = prop.table(num_firm),
                             sales_shares = prop.table(sales)),
                     by = df_id]

      entry_exit_dta[, ave := sales/num_firm]

      NT_pre <- entry_exit_dta[svyear == pre_year, .(svyear = yyear,
                                            num_firm_pre = sum(num_firm)),
                               by = c(df_id[df_id != "svyear"])]

      entry <- merge(entry_exit_dta,
                            NT_pre,
                            by  = df_id)

      entry[, num_rel_pre := (num_firm/ num_firm_pre)]

      ER <-dcast(entry,
            formula = as.formula(paste(paste(df_id, collapse = " + "), "~", rel_col )),
            value.var = "num_rel_pre")[, .(ER =  entrant),
                                        by = df_id]

      XR <- dcast(entry_exit_dta[svyear == pre_year],
                  formula = as.formula(paste(paste(df_id, collapse = " + "), "~", rel_col )),
                  value.var = "num_shares")[, .(XR = exit),
                                            by = df_id]
      ER_XR <- merge( ER[, svyear:= as.character(svyear)][, svyear:= year_pair],
                      XR[, svyear:= as.character(svyear)][, svyear:= year_pair],
                    by = df_id)


      ESH_XSH <- dcast(entry_exit_dta,
                     formula = as.formula(paste(paste(df_id, collapse = " + "), "~", rel_col )),
                  value.var = "sales_shares")[, .(ESH =  entrant,
                                                  XSH = exit),
                                              by = df_id]

      ESH_XSH <- merge( ESH_XSH[svyear == pre_year, .(svyear = year_pair,
                                                         XSH),
                                by =  c(df_id[df_id != "svyear"])],
                        ESH_XSH[svyear == (yyear), .(svyear = year_pair,
                                                     ESH),
                                by =  c(df_id[df_id != "svyear"])],
                      by = df_id)

      relative_size <- dcast(entry_exit_dta,
                     formula = as.formula(paste(paste(df_id, collapse = " + "), "~", rel_col )),
                     value.var = "ave")

      relative_size <- relative_size[, .(ERS = entrant/ incumbent,
                                         XRS = exit/incumbent),
                                     by = df_id]

      relative_size <- merge( relative_size[svyear == pre_year, .(svyear = year_pair,
                                                         XRS),
                                by =  c(df_id[df_id != "svyear"])],
                              relative_size[svyear == (yyear), .(svyear = year_pair,
                                                     ERS),
                                by =  c(df_id[df_id != "svyear"])],
                        by = df_id)

      final_dta <- merge(ER_XR, merge(ESH_XSH,
            relative_size,
            by = df_id),
            by = df_id)

      return(final_dta)

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
