suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
  library(rvest)
  library(purrr)
  library(tidyr)
  library(xml2)
  library(readr)
})


html_files <-
  list.files("data-raw", pattern = "*.html", full.names = TRUE)

progress_status <-
  html_files[6] %>%
  read_html() %>%
  html_nodes(".fa-adjust, .fa-check-circle, .fa-circle, .fa-times-circle") %>%
  html_attr("title") %>%
  replace_na("REMOVE")


html_list <-
  html_files[6] %>%
  read_html() %>%
  html_nodes("h1, h2, .title, ul.details > li, .fa-adjust, .fa-check-circle, .fa-circle, .fa-times-circle") %>%
  html_text()

html_list[!str_detect(html_list, pattern = "")] <-  progress_status
html_list


add_progress_status <- function(html) {
  html_list <-
    read_html(html) %>%
    html_nodes("h1, h2, .title, ul.details > li, .fa-adjust, .fa-check-circle, .fa-circle, .fa-times-circle") %>%
    html_text()

  progress_status <-
    read_html(html) %>%
    html_nodes(".fa-adjust, .fa-check-circle, .fa-circle, .fa-times-circle") %>%
    html_attr("title") %>%
    replace_na("REMOVE")

  html_list[!str_detect(html_list, pattern = "")] <-  progress_status
  html_list_complete <- html_list[html_list != "REMOVE"] # remove empty

  return(html_list_complete)
}

# add_progress_status(html_files[1])

iarpc_html_list <-
  map(
    html_files,
    add_progress_status
  )

iarpc_html_list[6]


html_df <-
  iarpc_html_list %>%
  unlist() %>%
  tibble() %>%
  mutate(
    research_goal = if_else(
      str_detect(., "^Performance elements assigned to*"),
      .,
      NA_character_
    )
  ) %>%
  fill(research_goal) %>%
  filter(. != research_goal) %>%
  mutate(research_goal = str_remove_all(
    research_goal,
    "Performance elements assigned to the ")
  ) %>%
  mutate(
    section_title = if_else(
      str_detect(., "^([:digit:])\\.([:digit:])\\s"),
      .,
      NA_character_
    )
  ) %>%
  fill(section_title) %>%
  filter(
    . != section_title
  ) %>%
  mutate(
    task = if_else(
      str_detect(., "^([:digit:])"),
      .,
      NA_character_
    )
  ) %>%
  fill(task) %>%
  filter(
    . != task
  ) %>%
  ## edited 2021-05-06
  mutate(
    progress_status = if_else(
      . %in% c("In progress", "Met", "No progress", "Deactivated/deferred"),
      .,
      NA_character_
    ),
    progress_status = lag(progress_status), ## Need to add a lag here. Process is for the group prior
    progress_status = if_else(
      str_detect(task, pattern = "2.1.1 Support planning, preparation, and implementation"),
      "In progress",
      progress_status
      ) # adding progress status for the first one manually due to lag
  ) %>%
  group_by(task) %>%
  fill(progress_status) %>%
  ungroup() %>%
  filter(. != progress_status) %>%
  ## edited 2021-04-18
  mutate(
    agency = if_else(
      str_detect(., "^Agency: "),
      .,
      NA_character_
    )
  ) %>%
  group_by(task) %>%
  fill(agency) %>%
  ungroup() %>%
  filter(. != agency) %>%

  mutate(
    lead_contact = if_else(
      str_detect(., "Lead contact:"),
      .,
      NA_character_
    )
  ) %>%
  group_by(task) %>%
  fill(lead_contact) %>%
  ungroup() %>%
  filter(. != lead_contact | is.na(lead_contact)) %>% # KEEP NA'S WHEN FILTERING!!

  mutate(
    last_update = if_else(
      str_detect(., "Last update: "),
      .,
      NA_character_
    )
  ) %>%
  group_by(task) %>%
  fill(last_update) %>%
  ungroup() %>%
  filter(. != last_update | is.na(last_update) | is.na(lead_contact)) %>%

  mutate(
    alignment = if_else(
      str_detect(., "Alignment"),
      .,
      NA_character_
    )
  ) %>%
  group_by(task) %>%
  fill(alignment, .direction = "up") %>%
  ungroup() %>%
  # filter(. != alignment | is.na(alignment) | is.na(last_update) | is.na(lead_contact)) %>%
  select(-.) %>%
  distinct()

## Save html_df as a back-up
write_csv(
  html_df,
  file = paste0("data-output/", Sys.Date(), "_iarpc_nested.csv")
)

# now clean and separate rows

iarpc_df <-
  html_df %>%
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
  mutate(alignment = if_else(alignment == "", NA_integer_, as.integer(alignment))) %>%
  # add columns for priority areas
  mutate(
    is_related_to_priority_area_1 = "",
    is_related_to_priority_area_2 = "",
    is_related_to_priority_area_3 = "",
    is_related_to_priority_area_4 = ""
  )

stopifnot(
  unique(html_df$task) %in% unique(iarpc_df$task)
)

saveRDS(
  iarpc_df,
  file = paste0("data-output/", Sys.Date(), "_iarpc_df.RDS")
)

write_csv(
  iarpc_df,
  file = paste0("data-output/", Sys.Date(), "_iarpc_df.csv")
)

message("file saved!")
