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
         section = fct_relevel(section, "MAIN")) %>%
  arrange(date, section, order)
df_songs <- read_rds('data/df_songs.rds')

dt_options <- list(lengthMenu = c(5, 10, 20, 50, 100, 200),
                   pageLength = 200, 
                   scrollY = "500px",
                   scrollCollapse = TRUE)

