
theme_nghiem <- function(base_size = 14) {
   theme_minimal(base_size = base_size) %+replace%
      theme(
         # L'ensemble de la figure
         plot.title = element_text(size = rel(1), face = "bold", margin = margin(0,0,5,0), hjust = 0),
         # Zone où se situe le graphique
         panel.grid.minor = element_blank(),
         panel.border = element_blank(),
         # Les axes
         axis.title = element_text(size = rel(0.85)),
         axis.text = element_text(size = rel(0.70)),
         #axis.line = element_line(color = "black", arrow = arrow(length = unit(0.3, "lines"), type = "closed"))
         # La légende
         legend.title = element_text(size = rel(0.85), face = "bold"),
         legend.text = element_text(size = rel(0.70)),
         legend.key = element_rect(fill = "transparent", colour = NA),
         legend.key.size = unit(1.5, "lines"),
         legend.background = element_rect(fill = "transparent", colour = NA),
         legend.position = "bottom"
      )
}

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
                      ownership,
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

   ## When I merge 2000 to concor 2001, I ignore data that have been dropped. I should have merged in before dropping with Stata data

      concor2000_2001 <- read_dta(here("inst", "Stata",
                                       "Changes to 2000 firm identifiers.dta"))

      dta[,  madn_unfix00 := madn]

      merged_dta <- merge(dta,
            concor2000_2001,
            by.x = c("madn"),
            by.y = c("madn00"),
            all.x = T)

      merged_dta[!is.na(madn01),  madn := madn01]

      dta <- merged_dta[, !c("madn01", "match")]

      dta <- VNFirmSurvey::EntryExit(geo_dta = dta,
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




      dta <- plant(dta_list = dta_list,
                                 years = year_length)

      return(dta)

}


# dn_dta <- lapply(dta_list, function(x) haven::read_dta(file = x,
#                                                        encoding = "latin1"))
#
# har_own_dta[, .(madn, province2003, vsic1993)][madn == 1]
#
# plant_00 <- VNFirmSurvey::plant(dta_list = dn_dta)


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
                                        svyear,
                                        ownership_type)]



      share_dta <- single_multi_plant[, `:=` (share_num = prop.table(num_firm),
                                          share_sales = prop.table(sales)),
                                      by = .(svyear,
                                             ownership_type)]


      graph_dta <- melt(share_dta[plant_num == F,
                                  .(count = share_num,
                                    revenue = share_sales,
                                    svyear,
                                    ownership_type) ],
                        id.vars = c("svyear", "ownership_type"),
                        variable.name = "shares")

      g <- ggplot(data = graph_dta[svyear < 2015] ,
                  aes(x = (svyear),
                      y = value,
                      group = ownership_type)) +
            geom_point(aes(col = ownership_type)) +
            geom_line(aes(col = ownership_type)) +
            labs(title = "Single-plant firms shares",
                 subtitle = "More than 90% of foreign and private firms are single-plant",
                 x = "Year",
                 y = "",
                 col = "Ownership") +
            scale_x_continuous(breaks = seq(2000, 2014, by = 2)) +
            facet_wrap(~shares) +
            scale_color_brewer(palette = "Dark2")

      ggsave(plot = g,
             filename = "single_plant_share.png",
             dpi = 300,
             path = here("inst", "tmp", "figure"))

      mean_plant <- dta[plant_num > 0, .(mean_plant_per_firm = mean(plant_num),
                                                     median_plant_per_firm = median(plant_num)),
                         by = .(svyear,
                                ownership_type)][order(svyear)]

      return(list(share_dta, mean_plant))
}




MarketShareOwnership <- function(dta_list){

   GetShare <- function(dta){

      share_dta <- dta[, .(rev = sum(revenue, na.rm = T)),
                       by = .(svyear, ownership_type)
      ][,  rev_share := prop.table(rev),
        by = .(svyear) ]

      return(share_dta)
   }

   dta_list <- lapply(dta_list, function(x) GetShare(x))

   dta_list[[1]]$manu <- "all"
   dta_list[[2]]$manu <- "manufacturing"

   graph_dta <- rbindlist(dta_list, fill = T,
                          use.names = T)


   g <- ggplot(graph_dta[ownership_type == "SOE"],
          aes(x = svyear,
              y = rev_share,
              col = manu)) +
      geom_point() +
      geom_line() +
      scale_x_continuous(breaks = seq(2000, 2016, by = 2))  +
      labs(x = "Year",
         y = "",
         title = "Revenue share of state-owned enterprise") +
      scale_color_brewer(palette = "Dark2")

   ggsave(g,
          filename = "market_share_own.png",
          path = here("inst", "tmp", "figure"))

   return(graph_dta)


}






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

      return(g)

}


EnExitDunne88 <- function(dta, year_list){

      df_id <- c("svyear")

      tmp <- rbindlist(lapply(year_list,
                              function(x)  PairEntryExit(dta = dta,
                                                      yyear = x,
                                                      year_gap = 5,
                                                      df_id = df_id)))

      tmp_ind <- rbindlist(lapply(year_list,
                              function(x)  PairEntryExit(dta = dta,
                                                         yyear = x,
                                                         year_gap = 5,
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


EntryExitDta <- function(dta,
                     yyear,
                     year_gap,
                     df_id = c("svyear"),
                     entry_exit = "both"){

   pre_year <-  yyear - year_gap

   rel_col <- paste0("status_", yyear, "rel_", pre_year)

   entry <- dta[svyear == yyear ,
                .(num_firm = .N,
                  sales = sum(revenue, na.rm = T)),
                by = c( df_id,  eval(rel_col))][, `:=` (num_shares = prop.table(num_firm),
                                                        sales_shares = prop.table(sales)),
                                                by = df_id]

   exit <- dta[svyear == pre_year ,
               .(num_firm = .N,
                 sales = sum(revenue, na.rm = T)),
               by = c( df_id,  eval(rel_col))][, `:=` (num_shares = prop.table(num_firm),
                                                       sales_shares = prop.table(sales)),
                                               by = df_id]


   if (entry_exit == "entry"){

      return(entry)

      }
   else if(entry_exit == "exit"){

         return(exit)

      }
   else{
      return(list(entry, exit))
   }

}

CastStatus <- function(dta,
                       yyear,
                       year_gap,
                       df_id = c("svyear"),
                       value_name ){

   pre_year <-  yyear - year_gap

   rel_col <- paste0("status_", yyear, "rel_", pre_year)

   tmp <- dcast(dta,
              formula = as.formula(paste(paste(df_id, collapse = " + "),
                                         "~",
                                         rel_col )),
              value.var = value_name)

   return(tmp)


}


PairEntryExit <- function(dta,
                       yyear,
                       year_gap,
                       df_id) {

      pre_year <-  yyear - year_gap

      rel_col <- paste0("status_", yyear, "rel_", pre_year)

      year_pair <-  paste(pre_year, yyear, sep = "-")


      entry_exit_dta <-  EntryExitDta(dta = dta,
                                     yyear = yyear,
                                     year_gap = year_gap,
                                     df_id = df_id)


      entry_exit_dta  <- rbindlist(entry_exit_dta)

      # entry_exit_dta[, `:=` (num_shares = prop.table(num_firm),
      #                        sales_shares = prop.table(sales)),
      #                by = df_id]

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



AggEntryYear <- function(dta, year_list ){


      dta <- lapply(year_list,
                    function(x) EntryExitDta(dta = dta,
                                         yyear = x,
                                         year_gap = 1,
                                         entry_exit = "entry"))

      # dta <- lapply(dta, function(x)
      #             x[, `:=` (n_share =  prop.table(num_firm),
      #             sale_share = prop.table(sales))])

      tmp <- mapply(function(x,y) CastStatus(dta = x,
                        yyear = y,
                        year_gap = 1,
                        value_name = "num_shares"),
                    x = dta,
                    y = year_list,
                    SIMPLIFY = F)

      graph_dta <- rbindlist(tmp)

      g <- ggplot(graph_dta,
                  aes(x =  factor(svyear),  y = entrant)) +
            geom_line(group = 1, color= "steelblue", size = 1) +
            geom_point(alpha = 0.3) +
            labs(title = "Entrant share (%)",
                 subtitle = "Fraction of entrants among all surveyed firms in a year",
                 caption = "Source: Annual Firm Survey 2001-2015",
                 x = "Year",
                 y = "")


      return(list(graph_dta, g))
}



CohortDta <- function(dta){

   dta <- dta[, cohort := min(svyear), by = madn]

   cohort_share <- dta[, .(num = .N,
                              sales = sum(revenue, na.rm = T)),
                            by = .(svyear, cohort )
                            ][, `:=` (num_shares = prop.table(num),
                                      sales_shares = prop.table(sales)),
                              by = .(svyear)]

   cohort_share[,  year_ave_size := mean(sales, na.rm = T),
                by = .(svyear)]

   cohort_share[,  cohort_ave_size := (mean(sales, na.rm = T)/ year_ave_size) ,
                by = .(svyear, cohort)]

   cohort_init_size  <- cohort_share[cohort == svyear, .(cohort,
                                                         init_size = num)]


   cohort_share <- merge(cohort_share,
                          cohort_init_size,
                          by = c("cohort"))[, exit_rate := (1-  num/init_size) ]

   return(cohort_share)
}


GraphCohort <- function(cohort_dta){

   cohort_list <- c(2001, 2005, 2010, 2015)
   year_list <- c(2001, 2005, 2010, 2015)

   graph_list <- list()

   g_dta <- cohort_dta[(cohort %in% cohort_list) &
                               (svyear %in% year_list)][order(svyear)]


   graph_list[['Market Share']] <- ggplot(data = g_dta,
                      aes(x = (svyear),
                          y = sales_shares,
                          group = factor(cohort) )) +
      geom_point(aes(color =  factor(cohort)),
                 size = 3) +
      geom_line(aes(color =  factor(cohort)), alpha = 0.5) +
      scale_x_continuous(limits=c(2000, 2015))+
      labs(x = "Year",
           color = "Cohort",
           y = "",
           title = "Sales shares (%) by cohort over time") +
      scale_color_brewer(palette = "Dark2")

   graph_list[['Avg Size']]  <- ggplot(data = g_dta,
                      aes(x = (svyear),
                          y = cohort_ave_size,
                          group = factor(cohort) )) +
      geom_point(aes(color =  factor(cohort)),
                 size = 3) +
      geom_line(aes(color =  factor(cohort)), alpha = 0.5) +
      scale_x_continuous(limits=c(2000, 2015))+
      labs(x = "Year",
           color = "Cohort",
           y = "",
           title = "Average Size of Surviving Firms Relative to All Firms") +
      scale_color_brewer(palette = "Dark2")

   graph_list[['Exit']]  <- ggplot(data = g_dta[cohort != svyear],
                        aes(x = (svyear),
                            y = exit_rate,
                            group = factor(cohort) )) +
      geom_point(aes(color =  factor(cohort)),
                 size = 3) +
      geom_line(aes(color =  factor(cohort)), alpha = 0.5) +
      scale_x_continuous(limits=c(2000, 2015))+
      labs(x = "Year",
           color = "Cohort",
           y = "",
           title = "Cumulative Cohort Exit Rates") +
      scale_color_brewer(palette = "Dark2")

   return(graph_list)
}


fancy_scientific <- function(l) {
      # turn in to character string in scientific notation
      l <- format(l, scientific = TRUE)
      # quote the part before the exponent to keep all the digits
      #l <- gsub("^(.*)e", "'\\1'e", l)
      # turn the 'e+' into plotmath format
      #l <- gsub("e", "%*%10^", l)
      # return this as an expression
      parse(text=l)
}

SaleDist <- function(dta, name){

      mean_sale <- dta[, mean_rev := mean(revenue, na.rm = T), by = .(svyear)]

      size_dta <- dta[, .(year = factor(year), madn,
                                               norm_sales = revenue/mean_rev)]


      q_tab <- size_dta[, .(q = seq(0, 1, 0.04)*100,
                             value = quantile(norm_sales, probs = seq(0, 1, 0.04),
                           na.rm = T)),
                         by = .(year)]

      # q_tab <- data.table("q" = seq(0, 1, 0.04)*100,
      #        "value" = size_q)

      g <- ggplot(q_tab[q < 100 & q > 5 & year %in% c(2001, 2010) ],
             aes(x = q, y = value, group = year)) +
            geom_point(aes(color = year)) +
            scale_y_continuous(trans = "log10",
                               limits = c(0.001, NA),
                               labels=fancy_scientific) +
            scale_x_continuous(#trans = "log10",
                               limits = c(0, 100))  +
            labs(x = "Firm Size Percentile",
                 y = "",
                 title =  "Sales of Percentile / Mean Sales",
                 color = "Year") +
            scale_color_brewer(palette = "Dark2")  +
            theme(legend.position = "right")


      ggsave(g,
             dpi = 300,
             filename = paste0(name, "_sale_dist.png"),
             path = here("inst", "tmp", "figure"))

      return(g)


}


NumWorkerDist <- function(dta, name){

   dta <- dta[svyear %in% c(2001, 2005, 2010 )]

   size_dist <-  dta[, .N , by = .(svyear, empend)][, frac := N/(sum(N)), by = svyear]

   PlotDis <- function(dta){

      g <- ggplot(data = dta,
             aes(x = empend, y = frac,
                 fill = factor(svyear) )) +
         scale_x_binned(n.breaks = 10) +
         geom_bar(stat = 'identity',
                  position = "dodge") +
         scale_y_continuous(labels=percent) +
         labs(x = "Firm Size by Employment",
              y  = "",
              fill = ""
              #title = "0 < Employment < 200 "
              ) +
         scale_fill_brewer(palette = "Dark2") +
         theme(legend.position =  "bottom")

      return(g)
   }


   g_small <- PlotDis(size_dist[empend < 200 & empend > 0])

   g_10 <- PlotDis(size_dist[empend < 200 & empend > 10])

   g_50 <- PlotDis(size_dist[empend < 200 & empend > 50])

   g_large <- PlotDis(size_dist[empend < 3000 & empend > 200])


   g <- plot_grid( g_small, g_10,
                  g_50, g_large)

   ggsave(g,
          dpi = 300,
          filename = paste0(name, "_emp_dist.png"),
          path = here("inst", "tmp", "figure"))


   return(g)
}


HarOwnership <- function(dta,
                         own_cross){

   merged_dta <- merge(dta[, year := as.factor(year)],
         own_cross[, year := as.factor(year)],
         by = c("year", "ownership"))


   return(merged_dta)

}



OwnCrossWalk  <- function(own_cross){

   ownership_crosswalk <- fread(own_cross, header = T)


   own_cross <- melt(ownership_crosswalk[, !c("description")],
                     id.vars = "ownership_type",
                     value.name = "ownership",
                     variable.name = "year"
   )[!is.na(ownership)]


   return(own_cross)

}





