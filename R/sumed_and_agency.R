suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(forcats)
  library(here)
})

data_raw <- here("data-raw/")
data_output <- here("data-output/")

iarpc_file_name <- "2021-05-24_iarpc_coded_df_sums.rds"

iarpc_reconciled_df <-
  read_rds(
    paste0(data_output, "/", iarpc_file_name)
  )

# Add in Agency
iarpc_df_name <- "2021-05-21_iarpc_df.RDS"
iarpc_df <-
  read_rds(
    paste0(data_output, "/", iarpc_df_name)
  )

# join
joined_iarpc_reconciled_df <-
  iarpc_df %>%
  filter(is_lead_agency) %>%
  select(task, agency) %>%
  rename("lead_agency" = "agency") %>%
  right_join(iarpc_reconciled_df, by = "task") %>%
  select(-starts_with("is_related_to"))


write_csv(
  joined_iarpc_reconciled_df,
  paste0(data_output, "/", Sys.Date(), "_joined_sumed_iarpc_with_agency.csv")
)

write_rds(
  joined_iarpc_reconciled_df,
  paste0(data_output, "/", Sys.Date(), "_joined_sumed_iarpc_with_agency.rds")
)
