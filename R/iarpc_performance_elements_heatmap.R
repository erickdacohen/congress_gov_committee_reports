suppressPackageStartupMessages({
  library(readxl)
  library(here)
  library(janitor)
  library(tidyr)
  library(dplyr)
  library(ggplot2)
  library(RColorBrewer)
})

theme_set(theme_light())

data_raw <- here("data-raw")
data_output <- here("data-output")
todays_date <- Sys.Date()


iarpc_coded_filename <- "iarpc_performance_elements_stpi_code.xlsx"

iarpc_coded_raw <-
  read_excel(
    paste(data_raw, iarpc_coded_filename, sep = "/")
    ) %>%
  clean_names()


iarpc_coded_df <-
  iarpc_coded_raw %>%
  select(
    -c("pa_notes", "fa_notes")
  ) %>%
  mutate(
    across(
      starts_with("pa") | starts_with("fa"),
    ~ replace_na(.x, 0)
    ),
    ## ensure everything is either 1 or 0
    across(
      starts_with("pa") | starts_with("fa"),
      ~ if_else(. != 1, 0, 1)
    )
  ) %>%
  pivot_longer(
    cols = c(pa1_health_resilience:fa5_tech_and_innovation)
  )
#%>%
  # group_by(task) %>%
  # summarise(sum_val = sum(value)) %>%
  # ungroup()

iarpc_coded_df %>%
  ## make factor
  mutate(
    across(
      starts_with("pa") | starts_with("fa"),
      as.factor
    )
  ) %>%
  filter(primary_stpi_assignment != "All") %>%
  ggplot(aes(x = primary_stpi_assignment, y = name, fill = value)) +
  geom_tile() +
  # scale_fill_viridis_c()
  scale_fill_distiller(palette = "RdPu")

iarpc_coded_df %>%
  ## make factor
  mutate(
    across(
      starts_with("pa") | starts_with("fa"),
      as.factor
    )
  ) %>%
  filter(!is.na(secondary_stpi_assignment)) %>%
  ggplot(aes(x = secondary_stpi_assignment, y = name, fill = value)) +
  geom_tile() +
  # scale_fill_viridis_c()
  scale_fill_distiller(palette = "RdPu")


