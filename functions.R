library(tidyverse)
library(rvest)

extract_setlist <- function(url) {
  live <- url %>%
    read_html() %>%
    html_nodes(xpath = "//div[@class = 'section clearfix']")
  
  songs <- live %>%
    html_nodes(., xpath = "//ul[@class = 'right']") %>%
    map(~html_nodes(., "li")) %>%
    map(~html_text(.)) %>%
    map(~str_remove(., "\r\n"))
  
  sections <- live %>%
    html_nodes(., "h2") %>%
    map(~html_text(.)) %>%
    map(~str_remove(., "\r\n")) %>%
    map(str_trim)
  sections[[1]][1] <- "MAIN"
  
  info <- url %>%
    read_html() %>%
    html_nodes(xpath = "//div[@class = 'header']")
  
  title <- info %>%
    html_node("h1") %>%
    html_text() %>%
    str_remove_all("[\\r\\n『』]")
  
  date_venue <- info %>%
    html_node("p") %>%
    html_text() %>%
    str_remove_all("[\\r\\n]") %>%
    str_split_fixed(pattern = "/", n = 2) %>%
    str_trim()
  
  
  df <- tibble(date = date_venue[1],
               venue = date_venue[2],
               section = sections,
               song = songs) %>%
    unnest(song, .drop = FALSE) %>%
    unnest() %>%
    group_by(section) %>%
    mutate(order = row_number(),
           date = lubridate::ymd(date)) %>%
    select(date, venue, section, order, song)
  
  return(df)
}