# Script to combine reconciled doc and lead agency

suppressPackageStartupMessages({
  library(dplyr)
  library(here)
  library(readr)
  library(readxl)
  library(janitor)
})

data_raw <- here("data-raw/")
data_output <- here("data-output/")

condensed_file_name <- "PE Assignments Condensed_Reconciled.xlsx"
iarpc_df_name <- "2021-05-21_iarpc_df.RDS"

condensed_file <-
  read_excel(
    paste0(data_raw, "/", condensed_file_name)
    ) %>%
  clean_names()

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
  left_join(condensed_file, by = "task") %>%
  select(-starts_with("is_related_to"))


write_csv(
  joined_iarpc_reconciled_df,
  paste0(data_output, "/", Sys.Date(), "_joined_iarpc_reconciled_df.csv")
)

write_rds(
  joined_iarpc_reconciled_df,
  paste0(data_output, "/", Sys.Date(), "_joined_iarpc_reconciled_df.rds")
)