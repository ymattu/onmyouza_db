library(tidyverse)
library(rvest)

source(here::here('functions.R'))

omz_bio <- "https://www.onmyo-za.net/biography/index.html"
omz_years <- 1999:lubridate::year(Sys.Date())

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

live_urls <- live_dates %>%
  map_chr(~str_c("https://www.onmyo-za.net/",
                 "setlist/",
                 .x,
                 ".html"
                 ))
live_urls <- live_urls[1:513] # 20190816まで

# セットリストの取得
setlist_all <- list()
for (i in seq_len(length(live_urls))) {
  Sys.sleep(2)
  cat(live_dates[i], "\n", sep = "")
  tryCatch(
    setlist_all[[i]] <- extract_setlist(live_urls[i]),
    error = function(e){print("Failed to extract")}
  )
  
}

df_setlist_all <- bind_rows(setlist_all)

saveRDS(df_setlist_all, here::here('data', 'df_setlists.rds'))

