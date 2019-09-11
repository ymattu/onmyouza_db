library(tidyverse)
library(rvest)

dvd_url <- 'http://www.onmyo-za.net/discography/videos.html'

dvd_info <- read_html(dvd_url) %>% 
  html_nodes(css = '#main > div.box.clearfix > div') %>% 
  html_nodes(css = "a[href *= 'video']")

dvd_links <- dvd_info %>%
  html_attr('href') %>%
  map_chr(~paste0('http://www.onmyo-za.net/discography/', .))

dvd_titles <- dvd_info %>%
  html_attr('title')

dvd_years <- dvd_info %>%
  html_text() %>%
  map_chr(~str_match(., '(?<=<).*?(?=年)')) #'<' と '年' に囲まれた部分

dvd_songs <- dvd_links %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.music_list > div > ul.center")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.))

# 絶界演舞は二枚組のため例外処理
zekkai_songs1 <- dvd_links[9] %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.album_list_two > div > ul.left")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.)) %>%
  purrr::flatten_chr() %>%
  str_replace_all("．", "") %>%
  str_replace_all("[0-9]", "") %>%
  str_trim()

zekkai_songs2 <- dvd_links[9] %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.album_list_two > div > ul.right")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.)) %>%
  purrr::flatten_chr() %>%
  str_replace_all("．", "") %>%
  str_replace_all("[0-9]", "") %>%
  str_trim()

zekkai_songs <- c(zekkai_songs1, zekkai_songs2)

dvd_songs[[9]] <- zekkai_songs

df_dvd_songs <- tibble(dvd_year = dvd_years,
                       dvd_title = dvd_titles,
                       song = dvd_songs) %>%
  unnest() %>%
  separate(col = dvd_title,
           into = c('dvd_title_kanji', 'dvd_title_yomi'),
           sep = '【') %>%
  mutate(dvd_title_kanji = str_remove_all(dvd_title_kanji,
                                      '[『』]'),
         dvd_title_yomi = str_remove(dvd_title_yomi, '】'),
         dvd_title_yomi = if_else(is.na(dvd_title_yomi),
                              'ぜっかいえんぶ',
                              dvd_title_yomi)) %>%
  filter(str_detect(song, "※") == F) %>% 
  group_by(dvd_title_kanji) %>%
  mutate(live_order = row_number())

saveRDS(df_dvd_songs, here::here('data', 'df_dvd_songs.rds'))
