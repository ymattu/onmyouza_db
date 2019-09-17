library(tidyverse)
library(rvest)

single_url <- 'http://www.onmyo-za.net/discography/single.html'

single_info <- read_html(single_url) %>% 
  html_nodes(css = '#main > div.box.clearfix > div') %>% 
  html_nodes(css = "a[href *= 'single']")

single_links <- single_info %>%
  html_attr('href') %>%
  map_chr(~paste0('http://www.onmyo-za.net/discography/', .))

single_titles <- single_info %>%
  html_attr('title')

single_years <- single_info %>%
  html_text() %>%
  map_chr(~str_match(., '(?<=<).*?(?=年)')) #'<' と '年' に囲まれた部分

single_types <- single_info %>%
  html_text() %>%
  map(~str_match_all(., '(?<=\r\n).*?(?=\r\n)')) %>%
  map_chr(~.[[1]][2,])

single_songs <- single_links %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.music_list > div > ul.center")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.))

single_writer <- single_links %>%
  map(read_html) %>%
  map(~html_node(., css = "#main > div.box.clearfix > div > div > div.album > div.music_list > div > ul.right")) %>%
  map(~html_nodes(., 'li')) %>%
  map(~html_text(.))

df_singles <- tibble(year = single_years,
                   type = single_types,
                   title = single_titles,
                   song = single_songs) %>%
  unnest() %>%
  separate(col = title,
           into = c('title_kanji', 'title_yomi'),
           sep = '【') %>%
  mutate(title_kanji = str_remove_all(title_kanji, '[『』※]'),
         title_yomi = str_remove(title_yomi, '】'))

saveRDS(df_singles, here::here('data', 'df_singles.rds'))
