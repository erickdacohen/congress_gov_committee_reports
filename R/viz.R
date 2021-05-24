# Viz
suppressPackageStartupMessages({
  library(readr)
  library(here)
  library(ggplot2)
  library(dplyr)
  library(forcats)
  library(tidyr)
})

theme_set(theme_light())

data_output <- here("data-output")
summed_agency_filename <- "2021-05-24_joined_sumed_iarpc_with_agency.rds"

iarpc_df <-
  read_rds(
    paste(data_output, summed_agency_filename, sep = "/")
  )

iarpc_df %>%
  pivot_longer(
    c(pa1_health_resilience:fa5_tech_and_innovation)
  )

# by agency
iarpc_df %>%
  pivot_longer(
    c(pa1_health_resilience:fa5_tech_and_innovation)
  ) %>%
  group_by(lead_agency) %>%
  summarise(
    sum = sum(value), .groups = "drop"
  ) %>%
  # ungroup() %>%
  filter(!is.na(lead_agency)) %>%
  mutate(
    lead_agency = as.factor(lead_agency) %>%
      fct_lump_n(n = 5)
    # lead_agency = fct_reorder(lead_agency, sum, .fun = median)
  )

  ggplot(aes(x = sum, y = lead_agency)) +
  geom_col()

