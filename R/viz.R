suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(forcats)
})

data_raw <- here("data-raw/")
data_output <- here("data-output/")

iarpc_file_name <- "2021-05-23_joined_iarpc_reconciled_df.rds"

iarpc_reconciled_df <-
  read_rds(
    paste0(data_output, "/", iarpc_file_name)
  )

iarpc_reconciled_df