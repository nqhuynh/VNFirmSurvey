
library(here)
library(data.table)
library(haven)

year <- c(2000:2017)

dta <- lapply(year,
       function(x) read_dta(here("Stata", "temp", paste0("dn", x, ".dta")),
                            n_max = 100))

combined_dta <- rbindlist(dta, fill = T)

write_dta(combined_dta,
          path = here("Stata", "temp", "combined_dta.dta"))
