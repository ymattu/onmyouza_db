library(tidyverse)
library(shiny)
library(DT)
library(leaflet)
# library(ggmap)

setlists_rds <- list.files(path = here::here('data'),
                           pattern = 'setlists',
                           full.names = T)

df_dvd_songs <- read_rds('data/df_dvd_songs.rds') %>%
  filter(!str_detect(song, '収録'))
df_setlists <- setlists_rds %>%
  map_dfr(read_rds) %>%
  ungroup() %>%
  mutate(section = as.factor(section),
         section = fct_relevel(section, "MAIN"),
         song = str_remove_all(song, '\r\n')) %>%
  arrange(date, section, order)
df_songs <- read_rds('data/df_songs.rds')

dt_options_dvd <- list(lengthMenu = c(5, 10, 20, 50, 100, 200),
                       pageLength = 200, 
                       scrollY = "500px",
                       scrollCollapse = TRUE,
                       dom = 'Blfrtip',
                       buttons = 
                         list(list(extend = 'collection',
                                   buttons = list(
                                     list(extend='csv', filename = 'omz_dvd_songs'),
                                     list(extend='excel', filename = 'omz_dvd_songs')
                                   ),
                                   text = 'Download')))
dt_options_setlist <- list(lengthMenu = c(5, 10, 20, 50, 100, 200),
                           pageLength = 200, 
                           scrollY = "500px",
                           scrollCollapse = TRUE,
                           dom = 'Blfrtip',
                           buttons = 
                             list(list(extend = 'collection',
                                       buttons = list(
                                         list(extend='csv', filename = 'omz_setlist'),
                                         list(extend='excel', filename = 'omz_setlist')
                                       ),
                                       text = 'Download')))
dt_options_album <- list(lengthMenu = c(5, 10, 20, 50, 100, 200),
                         pageLength = 200, 
                         scrollY = "500px",
                         scrollCollapse = TRUE,
                         dom = 'Blfrtip',
                         buttons = 
                           list(list(extend = 'collection',
                                     buttons = list(
                                       list(extend='csv', filename = 'omz_album_songs'),
                                       list(extend='excel', filename = 'omz_album_songs')
                                     ),
                                     text = 'Download')))

