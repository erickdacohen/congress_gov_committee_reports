library(dplyr)
library(ggplot2)
library(forcats)

theme_set(theme_bw())

iarpc_df <- readRDS("data-output/2021-04-13_iarpc_df.RDS")

agency_count <-
  iarpc_df %>%
  count(agency, sort = TRUE)

agency_lead_counts <-
  iarpc_df %>%
  count(agency, is_lead_agency, sort = TRUE) %>%
  filter(is_lead_agency) %>%
  select(-is_lead_agency)

iarpc_df %>%
  count(alignment, sort = TRUE)

agency_lead_counts %>%
  mutate(agency = as.factor(agency) %>%
           fct_inorder()
         ) %>%
  filter(n > 7) %>%
  ggplot(aes(x = n, y = agency, fill = agency)) +
  geom_col(show.legend = FALSE, alpha = 0.8) +
  labs(
    title = "Top Six Agency Leaders",
    x = "# of tasks leading",
    y = "Agency"
  )
