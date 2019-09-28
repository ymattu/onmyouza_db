library(tidyverse)
library(rvest)

album_url <- 'http://www.onmyo-za.net/discography/album.html'

album_info <- read_html(album_url) %>% 
  html_nodes(css = '#main > div.box.clearfix > div') %>% 
  html_nodes(css = "a[href *= 'album']")

album_links <- album_info %>%
  html_attr('href') %>%
  map_chr(~paste0('http://www.onmyo-za.net/discography/', .))

album_titles <- album_info %>%
  html_attr('title')

album_years <- album_info %>%
  html_text() %>%
  map_chr(~str_match(., '(?<=<).*?(?=年)')) #'<' と '年' に囲まれた部分

album_types <- album_info %>%
  html_text() %>%
  map(~str_match_all(., '(?<=\r\n).*?(?=\r\n)')) %>%
  map_chr(~.[[1]][2,])

album_songs <- album_links %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.music_list > div > ul.center")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.))

songs_writer <- album_links %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.music_list > div > ul.right")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.))

df_songs <- tibble(year = album_years,
                   type = album_types,
                   title = album_titles,
                   song = album_songs,
                   writer = songs_writer) %>%
  unnest() %>%
  separate(col = title,
           into = c('title_kanji', 'title_yomi'),
           sep = '【') %>%
  mutate(title_kanji = str_remove_all(title_kanji, '[『』]'),
         title_yomi = str_remove(title_yomi, '】'))

saveRDS(df_songs, here::here('data', 'df_songs.rds'))
