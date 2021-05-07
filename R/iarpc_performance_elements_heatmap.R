suppressPackageStartupMessages({
  library(readxl)
  library(here)
  library(janitor)
  library(tidyr)
  library(dplyr)
  library(ggplot2)
  library(RColorBrewer)
  library(forcats)
})

theme_set(theme_light())

data_raw <- here("data-raw")
data_output <- here("data-output")
todays_date <- Sys.Date()

iarpc_coded_filename <- "iarpc_performance_elements_stpi_code.xlsx"

# read in file
iarpc_coded_raw <-
  read_excel(
    paste(data_raw, iarpc_coded_filename, sep = "/")
    ) %>%
  clean_names()

# clean-up!
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
  )

# add up the results from round 1 and 2
iarpc_coded_df_sums <-
  iarpc_coded_df %>%
  group_by(task) %>%
  mutate(
    across(
      starts_with("pa") | starts_with("fa"),
      ~ sum(.x)
    )
  ) %>%
  ungroup() %>%
  select(-round) %>%
  distinct()

write.csv(
  iarpc_coded_df_sums,
  file = paste0(data_output, "/", todays_date, "_iarpc_coded_df_sums.csv")
)

# Heatmap full
iarpc_coded_df_sums %>%
  filter(primary_stpi_assignment != "All") %>%
  pivot_longer(
    cols = c(pa1_health_resilience:fa5_tech_and_innovation)
  ) %>%
  mutate(
    name = as.factor(name),
    name = fct_rev(name) # like fct_inorder reversed
  ) %>%

  ggplot(aes(x = task, y = name, fill = value)) +
  geom_tile() +
  labs(
    title = "Heatmap IARPC Priority Areas and Foundational Activities",
    x = "Task",
    y = NULL,
    fill = "Score"
  ) +
  theme(
    axis.text.x = element_blank(),
    axis.text = element_text(size = 14)
    ) +
  scale_fill_continuous(low = "white", high = "blue")



