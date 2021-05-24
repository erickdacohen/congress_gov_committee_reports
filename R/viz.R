# Viz
suppressPackageStartupMessages({
  library(readr)
  library(here)
  library(ggplot2)
  library(dplyr)
  library(forcats)
  library(tidyr)
  library(stringr)
})

theme_set(theme_light())

data_output <- here("data-output")
summed_agency_filename <- "2021-05-24_joined_sumed_iarpc_with_agency.rds"

iarpc_df <-
  read_rds(
    paste(data_output, summed_agency_filename, sep = "/")
  ) %>%
  select(-c(ends_with("_stpi_assignment")))

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
  ungroup() %>%
  filter(!is.na(lead_agency)) %>%
  mutate(
    lead_agency = as.factor(lead_agency),
    lead_agency = fct_reorder(lead_agency, sum, .fun = median)
  ) %>%
  ggplot(aes(x = sum, y = lead_agency)) +
  geom_col(fill = "dark red") +
  labs(
    title = "Lead Agency Goals Scores",
    x = "Score",
    y = "Lead Agency"
  ) +
  theme(text = element_text(size = 14))

# For each PA / FA
## PA
iarpc_df %>%
  pivot_longer(
    c(pa1_health_resilience:pa4_risk_management)
  ) %>%
  mutate(
    name = str_replace_all(name, pattern = "_", replacement = " ")
  ) %>%
  ggplot(aes(x = name, y = value)) +
  geom_col(fill = "dark red") +
  labs(
    title = "Priority Area Scores",
    x = "Priotiry Area",
    y = "Sum of Scores"
    ) +
  theme(text = element_text(size = 14))

## FA
iarpc_df %>%
  pivot_longer(
    c(fa_1_coproduction_of_knowledge:fa5_tech_and_innovation)
  ) %>%
  mutate(
    name = str_replace_all(name, pattern = "_", replacement = " ")
  ) %>%
  ggplot(aes(x = name, y = value)) +
  geom_col(fill = "dark red") +
  labs(
    title = "Foundational Activity Scores",
    x = "Foundational Activity",
    y = "Sum of Scores"
  ) +
  theme(text = element_text(size = 14)) +
  coord_flip()


