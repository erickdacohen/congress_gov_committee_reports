library(magrittr)
library(stringr)
library(rvest)

process <- function(filename) {
  text <- readLines(filename)

  team <-  grep("<h1>", text)
  sections <- grep("<h2>", text)
  subsections <- grep("class=\"title\"", text)
  agencies <- grep("Agency:", text)
  leads <- grep("Lead contact:", text)

  # browser()

  text[sort(c(team, sections, subsections, agencies, leads))] %>%
    str_replace_all("<[^>]+>", "") %>%
    paste(collapse = "\n")
}

process("data-raw/Performance elements assigned to the Atmosphere research goal - IARPC.html")

txt <- xml2::read_html("data-raw/Performance elements assigned to the Atmosphere research goal - IARPC.html")

purrr::map(
  txt %>%
    html_nodes("li.current"),

  ~.x %>% html_nodes(".title, ul.details > li") %>% html_text() %>%
    matrix(nrow = 1, byrow = FALSE) %>%
    tibble::tibble()
)


#
# txt %>%
#   html_nodes("h1, h2, .title, ul.details > li")
#
#



result <-
  purrr::map_df(
    list.files("../Downloads/", "\\.html$", full.names = TRUE),

    ~process(.x)
  )




