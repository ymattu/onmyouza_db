library(tidyverse)
library(rvest)
library(lubridate)

#' Extract Sewtlist from a URL
#' 
#' @param  url URL
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
    unnest_longer(song) %>%
    unnest(cols = c(date, venue, section)) %>%
    group_by(section) %>%
    mutate(order = row_number(),
           date = lubridate::ymd(date)) %>%
    select(date, venue, section, order, song)
  
  return(df)
}

#' Update Setlist Data
#' 
update_setlist_data <- function() {
  omz_bio <- "https://www.onmyo-za.net/biography/index.html"
  df_setlists <- read_rds('data/df_setlists.rds')
  db_latest <- df_setlists$date %>% tail(1)
  omz_years <- year(df_setlists$date %>% tail(1) + days(1)):year(Sys.Date())
  
  # 活動履歴のURL一覧
  rireki_years <- omz_years %>%
    as.character() %>%
    map_chr(~if_else(tail(.) == as.character(lubridate::year(Sys.Date())),
                     "index",
                     .))
  rireki_base <- "https://www.onmyo-za.net/biography/"
  rireki_urls <- rireki_years %>%
    map_chr(~str_c(rireki_base,
                   .,
                   ".html"
    ))
  
  message("Extracting Differences Between DB & Lives..")
  # ライブ日程
  live_dates <- rireki_urls %>%
    map(
      ~{Sys.sleep(1)
        read_html(.) %>%
          html_nodes(.,"a") %>%
          html_attr(., "onclick") %>%
          str_subset(., "setlist") %>%
          str_match_all(., "[0-9]{8}") %>%
          purrr::flatten_chr(.)
      }
    ) %>%
    purrr::flatten_chr()
  
  # 既存DBとの差分のみを抽出
  db_latest_chr <- db_latest %>%
    as.character() %>%
    str_remove_all("-")
  
  live_dates2 <- live_dates[live_dates > db_latest_chr]
  
  live_urls <- live_dates2 %>%
    map_chr(~str_c("https://www.onmyo-za.net/",
                   "setlist/",
                   .x,
                   ".html"
    ))
  
  message("Extracting Setlists...")
  # セットリストの取得
  setlist_new <- list()
  for (i in seq_len(length(live_urls))) {
    Sys.sleep(2)
    cat(live_dates2[i], "\n", sep = "")
    tryCatch(
      setlist_new[[i]] <- extract_setlist(live_urls[i]),
      error = function(e){print("Failed to extract")}
    )
    
  }
  
  df_setlist_new <- bind_rows(setlist_new)
  
  message("Saving New Data...")
  saveRDS(df_setlist_new,
          here::here('data',
                     glue::glue('df_setlists_updated{today()}.rds')))
}