library(dplyr)
library(stringr)
library(rvest)
library(purrr)
library(tidyr)


html_files <-
  list.files("data-raw", pattern = "*.html", full.names = TRUE)

iaprc_html_list <-
  purrr::map(
    html_files,

    ~xml2::read_html(.x) %>%
      html_nodes("li.current")
  ) %>%
  purrr::map(
    ~ .x %>%
      # html_nodes(".title, ul.details > li") %>%
      html_nodes("h1, h2, .title, ul.details > li") %>%
      html_text()
  )



html_mat <-
  map(
    html_files,
    ~ xml2::read_html(.x) %>%
      html_nodes("li.current") %>%
      html_nodes(".title, ul.details > li") %>%
      html_text()
  )

html_df <-
  html_mat %>%
  unlist() %>%
  tibble::tibble() %>%
  mutate(
    is_title = str_detect(., "^([:digit:])"),
    section_title = if_else(is_title, ., NA_character_)
  ) %>%
  rename(c("iarpc_html" = .)) %>%
  fill(section_title) %>%
  filter(!is_title) %>%
  select(!is_title) %>%
  add_count(section_title) %>%
  group_by(section_title) %>%
  group_split() %>%
  map(
    function(.x){
      add_row(.x, iarpc_html = "Lead contact:") %>%
      add_row(iarpc_html = "Alignment") %>%
        fill(section_title) %>%
        group_by(section_title) %>%
        filter(row_number() < 5) %>%
        ungroup()
  }
  ) %>%
  bind_rows()


iarpc_df <-
  html_df %>%
  mutate(
    section_title,
    is_agency = str_detect(iarpc_html, pattern = "Agency: *"),
    is_last_update = str_detect(iarpc_html, pattern = "Last update:"),
    is_lead_contact = str_detect(iarpc_html, pattern = "Lead contact:"),
    is_alignment = str_detect(iarpc_html, pattern = "Alignment"),

    agency = if_else(is_agency, iarpc_html, NA_character_),
    last_update = if_else(is_last_update, iarpc_html, NA_character_),
    lead_contact = if_else(is_lead_contact, iarpc_html, NA_character_),
    alignment = if_else(is_alignment, iarpc_html, NA_character_)
  ) %>%
  select(
    -c(starts_with("is_"), iarpc_html, n)
  ) %>%
  group_by(section_title) %>%
  fill(c(agency:alignment)) %>%
  ungroup() %>%
  na.omit(alignment) %>%
  mutate(
    agency = str_replace_all(agency, "Agency: ", ""),
    last_update = str_replace_all(last_update, "Last update: ", ""),
    lead_contact = str_replace_all(lead_contact, "Lead contact:", ""),
    alignment = str_trim(alignment) %>%
      str_replace_all("Alignment with 2016 Arctic Science Ministerial Deliverable: ", "") %>%
      str_replace_all("Alignment", "") %>%
      str_trim()
  ) %>%
  separate_rows(agency, sep = ", ") %>%
  separate_rows(alignment, sep = ", ") %>%
  # The first agency listed is for each section is the lead. Adding a boolean
  # for lead agency
  group_by(section_title) %>%
  mutate(
    is_lead_agency = if_else(row_number() == 1, TRUE, FALSE)
    ) %>%
  ungroup() %>%
  mutate(alignment = if_else(alignment == "", NA_integer_, as.integer(alignment)))


saveRDS(
  iarpc_df,
  file = paste0("data-output/", Sys.Date(), "_iarpc_df.RDS")
)

readr::write_csv(
  iarpc_df,
  file = paste0("data-output/", Sys.Date(), "_iarpc_df.csv")
)

message("file saved!")
